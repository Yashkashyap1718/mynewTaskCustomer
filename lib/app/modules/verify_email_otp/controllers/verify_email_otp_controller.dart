import 'dart:convert';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmailOtpController extends GetxController {
  OtpFieldController otpController = OtpFieldController();

  RxString emailID = "".obs;
  RxString otp = "".obs;
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
      emailID.value = argumentData['emailID'];
    }
    isLoading.value = false;
    update();
  }

  Future<void> reSendOTP(BuildContext context, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    final Map<String, String> payload = {
      "email_address": email, // Dynamic phone number input
    };

    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await http.post(
        Uri.parse(baseURL + sendOtpOnEmail),
        headers: {"Content-Type": "application/json", "token": token},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == true) {
          AnimatedSnackBar.material(
            'Otp resend on email $email',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 5),
            mobileSnackBarPosition: MobileSnackBarPosition.top,
          ).show(context);
        } else {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send OTP: ${response.reasonPhrase}'),
            ),
          );
        }
      } else {
        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: ${response.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      log('Error: $e'); // Log any errors
      ShowToastDialog.closeLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while sending request.'),
        ),
      );

      print(e);
    }
  }

  Future<void> confirmOTP(
      BuildContext context, String otp, String email) async {
    print("OTP::: $otp");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("token") ?? "";
    final Map<String, String> payload = {"otp": otp, "email_address": email};
    try {
      ShowToastDialog.showLoader("verify_OTP".tr);
      final http.Response response = await http.put(
        Uri.parse(baseURL + veriftOtpEmail),
        headers: {'Content-Type': 'application/json', "token": token},
        body: jsonEncode(payload),
      );
      print("VERIFIYOTEMAILLP:: ${response.body}");

      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("email", email);
        final Map<String, dynamic> data = jsonDecode(response.body);
        ShowToastDialog.closeLoader();
        if (data['status'] == true) {
          await Preferences().saveIsUserLoggedIn();
          Get.toNamed(Routes.HOME);
          UserData userData = UserData.fromJson(data["data"]);
          print("USERMODELSSSSSS: ${jsonEncode(userData)}");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("email", email);
          if (userData.name == null ||
              userData.name == "" ||
              userDataModel.gender == null ||
              userDataModel.gender == "") {
            Get.toNamed(Routes.SIGNUP, arguments: {'userToken': token});
          } else {
            await Preferences().saveIsUserLoggedIn();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.setString("email", email);
            Get.toNamed(Routes.HOME);
          }
          ShowToastDialog.closeLoader();
          AnimatedSnackBar.material(
            'Welcome! User $email',
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 5),
            mobileSnackBarPosition: MobileSnackBarPosition.top,
          ).show(context);
        } else {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data["msg"]}'),
            ),
          );
        }
      } else {
        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonDecode(response.body)['msg'].toString()),
          ),
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
    }
  }

  Future<void> fetchUserProfile(token, context) async {
    const String baseUrl =
        "https://travelteachergroup.com:8081/users/profile/preview";
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
            // Uncomment the languages field if required and handle its nullability
            // languages: (data['languages'] as List<dynamic>?)?.join(', ') ?? '',
            status: data['status'] ?? '', // Default to an empty string if null
            suspend: data['suspend'] ?? false, // Default to false if null
          );

          // Insert or update the user in the local database
          //  await DatabaseHelper().insertUser(userModel);
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
}
