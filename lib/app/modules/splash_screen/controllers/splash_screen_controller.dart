// ignore_for_file: unnecessary_overrides

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/intro_screen/views/intro_screen_view.dart';
import 'package:customer/app/modules/login/views/login_view.dart';
import 'package:customer/app/modules/permission/views/permission_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  redirectScreen() async {
    if ((await Preferences.getBoolean(Preferences.isFinishOnBoardingKey)) ==
        false) {
      Get.offAll(const IntroScreenView());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      log('-logugu--$isLogin' '');
      if (isLogin == true) {
        // bool permissionGiven = await Constant.isPermissionApplied();
        // log('---permission---$permissionGiven');
        // if (permissionGiven) {
        Get.offAll(const HomeView());
        return;
      } else {
        Get.offAll(const PermissionView());
        return;
      }
      // } else {
      // Get.offAll(const LoginView());
      // }
    }
  }
}
