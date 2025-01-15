import 'dart:convert';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpController extends GetxController {
  OtpFieldController otpController = OtpFieldController();

  RxString otpCode = "".obs;
  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;
  RxInt resendToken = 0.obs;
  RxBool isLoading = true.obs;

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
      // verificationId.value = argumentData['verificationId'];
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
      ShowToastDialog.showLoader("Please wait".tr);

      final http.Response response = await http.post(
        Uri.parse(baseURL + sendOtpEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      // log(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == true) {
          final String msg = responseData['msg'];
          final List<String> parts = msg.split(',');
          verificationId.value = parts.first.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData["msg"].toString()),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong please try again later'),
            ),
          );
        }
      } else {
        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong please try again later'),
          ),
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
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
    try {
      ShowToastDialog.showLoader("verify_OTP".tr);

      final http.Response response = await http.post(
        Uri.parse(baseURL + veriftOtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("VERIFIYOTP:: $data");
        ShowToastDialog.closeLoader();
        if (data['status'] == true) {
          final String token = data['token'];
          final String msg = data['msg'];
          final String id = data['id'];
          final String roleType = data['type'];
          final String firstDigit = id.substring(0, 1);
          final int firstDigitAsInt = int.parse(firstDigit, radix: 16);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("id", id);
          ShowToastDialog.closeLoader();

          await fetchUserProfile(token, context, data['email'] ?? false);
        } else {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong OTP entered'),
            ),
          );
        }
      } else {
        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong OTP entered'),
          ),
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while confirming OTP.'),
        ),
      );
    }
  }

  Future<void> fetchUserProfile(token, context, bool isEmialVerified) async {
    const String baseUrl =
        "https://travelteachergroup.com:8081/users/profile/preview";
    try {
      ShowToastDialog.showLoader("Please wait".tr);

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
          UserData userModel = UserData(
            id: data['_id'] ?? '', // Default to an empty string if null
            name: data['name'] ?? '', // Default to an empty string if null
            countryCode: data['country_code'] ??
                '', // Default to an empty string if null
            phone: data['phone'] ?? '', // Default to an empty string if null
            referralCode: data['referral_code'] ??
                '', // Default to an empty string if null
            verified: data['verified'] ??
                false, // Convert to string and default to 'false' if null
            role: data['role'] ?? '', // Default to an empty string if null
            status: data['status'] ?? '', // Default to an empty string if null
            suspend: data['suspend'] ??
                false, // Default to false if null  "phone" -> "9858585858"
          );
          ShowToastDialog.closeLoader();
          userDataModel = userModel;
          // await Preferences().saveIsUserLoggedIn();
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String email = preferences.getString("email") ?? "";
          if (isEmialVerified == false) {
            Get.toNamed(Routes.EMAIL_OTP);
          } else {
            await Preferences().saveIsUserLoggedIn();
            Get.toNamed(Routes.HOME);
          }
          AnimatedSnackBar.material(
            'Welcome! User $phoneNumber',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 5),
            mobileSnackBarPosition: MobileSnackBarPosition.top,
          ).show(context);
          // Get.toNamed(Routes.SIGNUP,arguments: {'userToken': token});
        } else {
          ShowToastDialog.closeLoader();

          AnimatedSnackBar.material(
            "Something went wrong",
            type: AnimatedSnackBarType.error, // Changed to error
            duration: const Duration(seconds: 5),
            mobileSnackBarPosition: MobileSnackBarPosition.top,
          ).show(context);
        }
      } else {
        ShowToastDialog.closeLoader();

        AnimatedSnackBar.material(
          "Something went wrong",
          type: AnimatedSnackBarType.error, // Changed to error
          duration: const Duration(seconds: 5),
          mobileSnackBarPosition: MobileSnackBarPosition.top,
        ).show(context);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();

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
