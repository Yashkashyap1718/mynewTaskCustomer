import 'dart:convert';

import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constant/api_constant.dart';
import '../../home/controllers/home_controller.dart';

class SignupController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  TextEditingController countryCodeController = TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString loginType = "".obs;
  RxString userToken = "".obs;
  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {}
  Rx<UserData> userModel = UserData().obs;
  final HomeController userController = Get.put(HomeController());

  creatCompleteAccorunt(String gender, String token) async {
    final Map<String, String> payload = {
      "name": nameController.text,
      "gender": gender,
      "referral_code": referralController.text,
    };
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await http.post(
        Uri.parse(baseURL + complpeteSignUpEndpoint),
        headers: {"Content-Type": "application/json", "token": token},
        body: jsonEncode(payload),
      );
      if(response.statusCode==200){
        ShowToastDialog.closeLoader();
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          Get.offAllNamed(Routes.HOME);
        } else {
          ShowToastDialog.showToast("Something went wrong!");
        }
      }else{
        ShowToastDialog.showToast("Something went wrong!");
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  getArgument() async {
    userModel.value = userDataModel;
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userToken.value = argumentData['userToken'];
      loginType.value = userModel.value.role.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.text = userModel.value.phone.toString();
        countryCodeController.text = userModel.value.countryCode.toString();
      } else {
        // referralController.text = userModel.value.email.toString();
        nameController.text = userModel.value.name.toString();
        referralController.text = userModel.value.referralCode.toString();
      }
    }
    update();
  }


}
