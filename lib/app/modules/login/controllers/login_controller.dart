// ignore_for_file: unnecessary_overrides, invalid_return_type_for_catch_error

import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/signup/views/signup_view.dart';
import 'package:customer/app/modules/verify_otp/views/verify_otp_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
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

  Future<void> sendOTP(BuildContext context) async {
    final Map<String, String> payload = {
      "country_code": "91", // Assuming you want to keep this static for now
      "mobile_number": phoneNumberController.text, // Dynamic phone number input
    };
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await http.post(
        Uri.parse(baseURL + sendOtpEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if(responseData["status"]==true){
          final String msg = responseData['msg'];
          final List<String> parts = msg.split(',');
          final String otp = parts.first.trim(); // Trim to remove any surrounding spaces
          print('Extracted OTP: $otp');
          ShowToastDialog.closeLoader();
          Get.toNamed(Routes.VERIFY_OTP,arguments: {"countryCode":"91","phoneNumber":phoneNumberController.text,"verificationId":otp});
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
