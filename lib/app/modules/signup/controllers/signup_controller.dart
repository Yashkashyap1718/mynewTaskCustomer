import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/utils/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constant/api_constant.dart';
import '../../home/controllers/home_controller.dart';

class SignupController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController referralController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString loginType = "".obs;

  DatabaseHelper db = DatabaseHelper();
  @override
  void onInit() {
    getArgument();

    super.onInit();
  }

  @override
  void onClose() {}
  Rx<UserModel> userModel = UserModel().obs;
  final HomeController userController = Get.put(HomeController());

  creatCompleteAccorunt(String gender, String token) async {
    final Map<String, String> payload = {
      "name": nameController.text,
      "gender": "Male",
      "referral_code": referralController.text,
    };
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      // final http.Response response = await http.post(
      //   Uri.parse(baseURL + complpeteSignUpEndpoint),
      //   headers: {'Content-Type': 'application/json', 'token': token},
      //   body: jsonEncode(payload),
      // );
  
      final response = await http.post(
        Uri.parse(baseURL + complpeteSignUpEndpoint),
        headers: {"Content-Type": "application/json", "token": token},
        body: jsonEncode(payload),
      );

      log('***************${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      // await db.cleanUserTable();

      if (data['status'] == true && data['data'] != null) {
        // UserModel userModel = UserModel();
        //
        // userModel.id = data['data']['_id'];
        // userModel.fullName = data['data']['name'];
        // userModel.gender = data['data']['gender'];
        // userModel.referralCode = data['data']['referral_code'];

        // await db.insertUser(userModel);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Get.offAll(() => HomeView(token: token));
        // You can proceed with further operations like saving the user model or updating UI
        print('User data loaded successfully');
      } else {
        // Handle the error case
        print(data['msg']); // Example: "Please sign in to continue."
      }

      ShowToastDialog.closeLoader();
    } catch (e) {
      log(e.toString());
      ShowToastDialog.showToast(e.toString());
    }
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.text = userModel.value.phoneNumber.toString();
        countryCodeController.text = userModel.value.countryCode.toString();
      } else {
        referralController.text = userModel.value.email.toString();
        nameController.text = userModel.value.fullName.toString();
      }
    }
    update();
  }

  createAccount() async {
    String fcmToken = await NotificationService.getToken();
    ShowToastDialog.showLoader("Please wait".tr);
    UserModel userModelData = userModel.value;
    userModelData.fullName = nameController.value.text;
    userModelData.slug = nameController.value.text.toSlug(delimiter: "-");
    userModelData.email = emailController.value.text;
    userModelData.countryCode = countryCodeController.value.text;
    userModelData.phoneNumber = phoneNumberController.value.text;
    userModelData.gender = selectedGender.value == 1 ? "Male" : "Female";
    userModelData.profilePic = '';
    userModelData.fcmToken = fcmToken;
    userModelData.createdAt = Timestamp.now();
    userModelData.isActive = true;
    userModelData.referralCode = referralController.text;

    await FireStoreUtils.updateUser(userModelData).then((value) {
      ShowToastDialog.closeLoader();
      if (value == true) {
        Get.offAll(const HomeView());
      }
    });
  }
}
