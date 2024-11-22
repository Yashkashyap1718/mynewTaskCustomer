import 'dart:convert';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/signup/views/signup_view.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/database_helper.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpController extends GetxController {
  TextEditingController otpConytroller = TextEditingController();
  RxString otpCode = "".obs;
  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;
  RxInt resendToken = 0.obs;
  RxBool isLoading = true.obs;

  String otp = '';

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {}

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'];
      phoneNumber.value = argumentData['phoneNumber'];
      verificationId.value = argumentData['verificationId'];
    }
    isLoading.value = false;
    update();
  }

  Future<void> reSendOTP(BuildContext context, String phoneNumbe) async {
    final Map<String, String> payload = {
      "country_code": "91",
      "mobile_number": phoneNumbe
    };

    try {
      // log(payload.toString());
      final http.Response response = await http.post(
        Uri.parse(baseURL + sendOtpEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String msg = responseData['msg'];
        final List<String> parts = msg.split(',');
        otp = parts.first.trim();

        print(otp);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(otp)),
        );
        // Get.to(
        //   VerifyOtpView(
        //     phoneNumder: phoneNumberController.text,
        //     oTP: otp,
        //   ),
        // );
      } else {
        throw Exception('Failed to send request');
      }
    } catch (e) {
      // log('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while sending request.'),
        ),
      );
    }
  }

  Future<bool> sendOTP() async {
    ShowToastDialog.showLoader("Please wait".tr);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: countryCode.value + phoneNumber.value,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId0, int? resendToken0) async {
        verificationId.value = verificationId0;
        resendToken.value = resendToken0!;
      },
      timeout: const Duration(seconds: 25),
      forceResendingToken: resendToken.value,
      codeAutoRetrievalTimeout: (String verificationId0) {
        verificationId0 = verificationId.value;
      },
    );
    ShowToastDialog.closeLoader();
    return true;
  }

  Future<void> confirmOTP(
      BuildContext context, String otp, String phoneNumber) async {
    final Map<String, String> payload = {
      "otp": otp,
      "mobile_number": phoneNumber,
    };

    log('---paylod---$otp---$phoneNumber');
    try {
      final http.Response response = await http.post(
        Uri.parse(baseURL + veriftOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == true) {
        final String token = data['token'];
        final String msg = data['msg'];
        final String id = data['id'];
        final String roleType = data['type'];
        final String firstDigit = id.substring(0, 1);
        final int firstDigitAsInt = int.parse(firstDigit, radix: 16);
        UserModel userModel = UserModel();
        userModel.fcmToken = token;

        await DatabaseHelper().insertUser(userModel);
        log('*****************User inserted with token: ${userModel.fcmToken}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        await Preferences().saveIsUserLoggedIn();

        await fetchUserProfile(token, context).then((value) {
          Get.off(SignupView(userToken: token));
        });
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setBool('isLoggedIn', true);

        ShowToastDialog.closeLoader();

        // Show success message with Animated SnackBar
        AnimatedSnackBar.material(
          'Welcome! User $phoneNumber',
          type: AnimatedSnackBarType.success,
          duration: const Duration(seconds: 5),
          mobileSnackBarPosition: MobileSnackBarPosition.top,
        ).show(context);
        // Store token or other relevant data in provider or local storage
        // provider.setAccessToken(token);

        // Navigate to HomeScreen or the relevant page
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        throw Exception('Failed to confirm OTP');
      }
    } catch (e) {
      debugPrint('Error: during OTP confirmation----------- $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while confirming OTP.'),
        ),
      );
    }
  }

  Future<void> fetchUserProfile(token, context) async {
    const String baseUrl = "http://172.93.54.177:3002/users/profile/preview";

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          final data = responseData['data'];
          // await DatabaseHelper().cleanUserTable();

          // Handle null values safely using the null-aware operator or providing default values.
          UserModel userModel = UserModel(
            id: data['_id'] ?? '', // Default to an empty string if null
            fullName: data['name'] ?? '', // Default to an empty string if null
            countryCode: data['country_code'] ??
                '', // Default to an empty string if null
            phoneNumber:
                data['phone'] ?? '', // Default to an empty string if null
            referralCode: data['referral_code'] ??
                '', // Default to an empty string if null
            verified: data['verified']?.toString() ??
                'false', // Convert to string and default to 'false' if null
            role: data['role'] ?? '', // Default to an empty string if null
            // Uncomment the languages field if required and handle its nullability
            // languages: (data['languages'] as List<dynamic>?)?.join(', ') ?? '',
            profilePic:
                data['profile'] ?? '', // Default to an empty string if null
            status: data['status'] ?? '', // Default to an empty string if null
            suspend: data['suspend'] ?? false, // Default to false if null
            gender: data['gender'] ?? '', // Default to an empty string if null
          );

          // Insert or update the user in the local database
          await DatabaseHelper().insertUser(userModel);
          print("************User profile successfully saved.");

          AnimatedSnackBar.material(
            'User profile successfully saved.',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 5),
            mobileSnackBarPosition: MobileSnackBarPosition.top,
          ).show(context);
        } else {
          print("***********Failed to fetch profile: ${responseData['msg']}");
        }
      } else {
        print("********Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching profile: $e");

      AnimatedSnackBar.material(
        e.toString(),
        type: AnimatedSnackBarType.error, // Changed to error
        duration: const Duration(seconds: 5),
        mobileSnackBarPosition: MobileSnackBarPosition.top,
      ).show(context);
    }
  }

  Future<void> verifyOtpWithFirebase(BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Verifying OTP...");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpCode.value,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // confirmOTP(context, otpCode.value, phoneNumber.value);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to verify OTP with Firebase.'),
          ),
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error during Firebase OTP verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during Firebase OTP verification.'),
        ),
      );
    } finally {
      ShowToastDialog.closeLoader();
    }
  }
}
