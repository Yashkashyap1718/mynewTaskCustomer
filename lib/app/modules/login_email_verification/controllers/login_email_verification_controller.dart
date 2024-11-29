// ignore_for_file: unnecessary_overrides, invalid_return_type_for_catch_error

import 'dart:convert';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginEmailVerificationController extends GetxController {
  TextEditingController emailController = TextEditingController();
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> sendOTPOnEmail(BuildContext context) async {
    if (!emailController.text.isEmail) {
      ShowToastDialog.showToast("Please provide valid email");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    final Map<String, String> payload = {
      "email_address": emailController.text, // Dynamic phone number input
    };

    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await http.post(
        Uri.parse(baseURL + sendOtpOnEmail),
        headers: {"Content-Type": "application/json", "token": token},
        body: jsonEncode(payload),
      );

      print("EMAIL OTP RESPONSE : ${response.body}");
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == true) {
          Get.toNamed(Routes.VERIFY_EMAIL_OTP,
              arguments: {"emailID": emailController.text});
          AnimatedSnackBar.material(
            'Otp send on email ${emailController.text}',
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
        print("EMAIlRESPONSE: $responseData");
        // // Extract the "msg" field which contains the OTP
        // final String msg = responseData['msg'];
        // // Split the message by comma to get the OTP (the first part)
        // final List<String> parts = msg.split(',');
        // final String otp = parts.first.trim(); // Trim to remove any surrounding spaces
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
}
