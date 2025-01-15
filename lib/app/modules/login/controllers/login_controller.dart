// ignore_for_file: unnecessary_overrides, invalid_return_type_for_catch_error

import 'dart:convert';

import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController(text: '');
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onInit() {
    phoneNumberController = TextEditingController(text: '');
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override 
  void onClose() {}

  Future<void> sendOTP(BuildContext context) async {
    try {
      final Map<String, String> payload = {
        "country_code": "91", // Assuming you want to keep this static for now
        "mobile_number":
            phoneNumberController.text, // Dynamic phone number input
      };
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await http.post(
        Uri.parse(baseURL + sendOtpEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == true) {
          final String msg = responseData['msg'];
          final List<String> parts = msg.split(',');
          final String otp =
              parts.first.trim(); // Trim to remove any surrounding spaces
          print('Extracted OTP: $otp');
          ShowToastDialog.closeLoader();
          Get.toNamed(Routes.VERIFY_OTP, arguments: {
            "countryCode": "91",
            "phoneNumber": phoneNumberController.text,
            "verificationId": otp
          });
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
