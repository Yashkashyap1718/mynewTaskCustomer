// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constant_widgets/show_toast_dialog.dart';
import '../../login/views/login_view.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  RxString profilePic =
      "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23"
          .obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  PageController pageController = PageController();
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;
  // var userModel = UserModel().obs;

  @override
  void onInit() {
    // getUserData();
    updateCurrentLocation();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  // Method to update the user data
  void updateUser(UserModel user) {
    // userModel.value = user;
  }

  getUserData() async {
    isLoading.value = true;

    UserModel? userModel = await FireStoreUtils.getUserProfile();
    await checkActiveStatus();
    if (userModel != null) {
      profilePic.value = (userModel.profilePic ?? "").isNotEmpty
          ? userModel.profilePic ??
              "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23"
          : "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23";
      name.value = userModel.fullName ?? '';
      phoneNumber.value =
          (userModel.countryCode ?? '') + (userModel.phoneNumber ?? '');
      userModel.fcmToken = await NotificationService.getToken();
      await FireStoreUtils.updateUser(userModel);
      await FireStoreUtils.getBannerList().then((value) {
        bannerList.value = value ?? [];
      });
    }
    await Utils.getCurrentLocation();
  }

  checkActiveStatus() async {
    UserModel? userModel = await FireStoreUtils.getUserProfile();
    if (userModel!.isActive == false) {
      Get.defaultDialog(
          titlePadding: const EdgeInsets.only(top: 16),
          title: "Account Disabled",
          middleText:
              "Your account has been disabled. Please contact the administrator.",
          titleStyle:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          barrierDismissible: false,
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          });
    }
  }

  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter:
              double.parse(Constant.driverLocationUpdate.toString()),
          interval: 2000);
      location.onLocationChanged.listen((locationData) {
        log("------>");
        log(locationData.toString());
        Constant.currentLocation = LocationLatLng(
            latitude: locationData.latitude, longitude: locationData.longitude);
        // FireStoreUtils
        //     .getDriverUserProfile(FireStoreUtils.getCurrentUid())
        //     .then((value) {
        //   // DriverUserModel driverUserModel = value!;
        //   // if (driverUserModel.isOnline == true) {
        //   //   driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
        //   //   GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
        //
        //   // driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
        //   // driverUserModel.rotation = locationData.heading;
        //   // FireStoreUtils.updateDriverUser(driverUserModel);
        // // }
        //     });
        log("------>1");
      });
    } else {
      location.requestPermission().then((permissionStatus) {
        log("------>3");
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter:
                  double.parse(Constant.driverLocationUpdate.toString()),
              interval: 2000);
          location.onLocationChanged.listen((locationData) async {
            Constant.currentLocation = LocationLatLng(
                latitude: locationData.latitude,
                longitude: locationData.longitude);
            log("------>4");

            // FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
            //   DriverUserModel driverUserModel = value!;
            //   if (driverUserModel.isOnline == true) {
            //     driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            //     driverUserModel.rotation = locationData.heading;
            //     GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
            //
            //     driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
            //
            //     FireStoreUtils.updateDriverUser(driverUserModel);
            //   }
            // });
          });
        }
        log("------>5");
      });
      log("------>6");
    }
    isLoading.value = false;
    update();
  }

  logOutUser(BuildContext context, String token) async {
    try {
      print('---logOutUser----function call-----');

      ShowToastDialog.showLoader("Please wait".tr);
      final res = await http.post(Uri.parse(baseURL + logOutEndpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'token': token}));

      print('---logOutUser----token-----$token');

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(res.body);

        print('---logOutUser----response-----$responseData');

        final String msg = responseData['msg'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        Get.offAll(const LoginView());

        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
          ),
        );
      }
    } catch (e) {
      print('-----logout-----error---$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout user: $e'),
        ),
      );
    }
  }
}
