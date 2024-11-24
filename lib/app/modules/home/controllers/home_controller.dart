// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      "https://avatar.iran.liara.run/public"
          .obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  PageController pageController = PageController();
  UserData? userData;
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;
  // var userData = userData().obs;

  @override
  void onInit() {
    getUserData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}


  sendLatLon(String lat, String lon) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCMTOKEN:: ${fcmToken}");
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
    if(fcmToken==null){
      return;
    }
    final Map<String, String> payload = {
      "latitude": lat,
      "longitude": lon,
      "fcmToken": fcmToken
    };
    try {
      final response = await http.put(
        Uri.parse(baseURL + updatedCurrentLocation),
        headers: {"Content-Type": "application/json", "token": token},
        body: jsonEncode(payload),
      );
      log('***************${response.body}');
      final Map<String, dynamic> data = jsonDecode(response.body);
      // await db.cleanUserTable();
      if (data['status'] == true && data['data'] != null) {

      } else {
        print(data['msg']); // Example: "Please sign in to continue."
      }
    } catch (e) {
      log(e.toString());
      ShowToastDialog.showToast(e.toString());
    }
  }



 void getUserData() async {
    isLoading.value = true;
    userData =  await FireStoreUtils.getUserProfileAPI();
    print("USERDATA::: ${userData}");
    if(userData != null){
      isLoading.value = false;
      if(userData!.status!="Active"){
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
        return;
      }
      profilePic.value ="https://avatar.iran.liara.run/public";
      name.value = userData!.name ?? '';
      phoneNumber.value = (userData!.countryCode ?? '91') + (userData!.phone ?? '****');

    }


    await Utils.getCurrentLocation();
    updateCurrentLocation();
    update();
  }




  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      //location.enableBackgroundMode(enable: true);
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
        sendLatLon(locationData.latitude.toString(),locationData.longitude.toString());

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
            sendLatLon(locationData.latitude.toString(),locationData.longitude.toString());

            // FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
            //   DriveruserData driveruserData = value!;
            //   if (driveruserData.isOnline == true) {
            //     driveruserData.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            //     driveruserData.rotation = locationData.heading;
            //     GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
            //
            //     driveruserData.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
            //
            //     FireStoreUtils.updateDriverUser(driveruserData);
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
        Get.offAllNamed(Routes.SPLASH_SCREEN);
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
