// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/login/views/login_view.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:customer/models/ride_booking.dart';

import '../../../../constant_widgets/show_toast_dialog.dart';

// sidhumusse wala
RideBooking? lastRide;

class HomeController extends GetxController {
  final count = 0.obs;

  RxString profilePic = "".obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  RxList<BannerModel> bannerList = <BannerModel>[].obs;
  PageController pageController = PageController();
  UserData? userData;
  RxInt curPage = 0.obs;
  RxInt drawerIndex = 0.obs;
  RxBool isLoading = false.obs;

  // var userData = userData().obs;

  final bookingModel = Rx<RideBooking?>(null);

  @override
  void onInit() {
    getUserData();
    // getData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  LatLng? sourceLocation;
  LatLng? destination;
  Position? currentLocationPosition;
  Position? currentLocationPosition2;
  GoogleMapController? mapController;

  getData() async {
    currentLocationPosition = await Utils.getCurrentLocation();

    Constant.country = (await placemarkFromCoordinates(
                currentLocationPosition!.latitude,
                currentLocationPosition!.longitude))[0]
            .country ??
        'Unknown';
    sourceLocation = LatLng(
        currentLocationPosition!.latitude, currentLocationPosition!.longitude);

    await addMarkerSetup();

    if (destination != null && sourceLocation != null) {
      getPolyline(
          sourceLatitude: sourceLocation!.latitude,
          sourceLongitude: sourceLocation!.longitude,
          destinationLatitude: destination!.latitude,
          destinationLongitude: destination!.longitude);

      currentLocationPosition2 = currentLocationPosition;
    } else {
      if (destination != null) {
        addMarker(
            latitude: destination!.latitude,
            longitude: destination!.longitude,
            id: "drop",
            descriptor: pickUpIcon!,
            rotation: 0.0);
        updateCameraLocation(destination!, destination!, mapController);
        currentLocationPosition2 = currentLocationPosition;
      } else {
        MarkerId markerId = const MarkerId("drop");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
        }
        log("==> ${markers.containsKey(markerId)}");
        currentLocationPosition2 = currentLocationPosition;
      }
      if (sourceLocation != null) {
        addMarker(
            latitude: sourceLocation!.latitude,
            longitude: sourceLocation!.longitude,
            id: "pickUp",
            descriptor: dropIcon!,
            rotation: 0.0);
      } else {
        MarkerId markerId = const MarkerId("pickUp");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
        }
        log("==> ${markers.containsKey(markerId)}");
        currentLocationPosition2 = currentLocationPosition;
      }
    }
    updateCameraLocation(destination!, destination!, mapController);
    currentLocationPosition2 = currentLocationPosition;
    isLoading.value = false;
  }

// Helper method to remove markers
  void removeMarker(String id) {
    MarkerId markerId = MarkerId(id);
    if (markers.containsKey(markerId)) {
      markers.removeWhere((key, value) => key == markerId);
      updateCameraLocation(
        LatLng(currentLocationPosition!.latitude,
            currentLocationPosition!.longitude),
        LatLng(currentLocationPosition!.latitude,
            currentLocationPosition!.longitude),
        mapController,
      );
    }
  }

  BitmapDescriptor? pickUpIcon;
  BitmapDescriptor? dropIcon;

  void getPolyline(
      {required double? sourceLatitude,
      required double? sourceLongitude,
      required double? destinationLatitude,
      required double? destinationLongitude}) async {
    print(
        "sourceLatitude:sourceLatitude $sourceLatitude  sourceLongitude: $sourceLongitude  destinationLatitude $destinationLatitude  destinationLongitude $destinationLongitude");
    if (sourceLatitude != null &&
        sourceLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineResult? result;
      try {
        result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: Constant.mapAPIKey,
          request: PolylineRequest(
            origin: PointLatLng(sourceLatitude, sourceLongitude),
            destination: PointLatLng(destinationLatitude, destinationLongitude),
            mode: TravelMode.driving,
          ),
        );
        print("HEMANTTTT:: ${result.points}");
      } catch (e) {
        log(" HEMANTTTT::HEMANTTTT:: Exception: $e");
      }
      /*  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: Constant.mapAPIKey,
          request: PolylineRequest(
              origin: PointLatLng(sourceLatitude, sourceLongitude), destination: PointLatLng(destinationLatitude, destinationLongitude), mode: TravelMode.driving)
          // PointLatLng(sourceLatitude, sourceLongitude),
          // request:  PointLatLng(destinationLatitude, destinationLongitude),
          // travelMode: TravelMode.driving,
          );*/
      if (result != null && result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          print("ENTRY::::::   ${point.latitude}");
        }
      } else {
        ShowToastDialog.showToast("Polly line error");
      }

      addMarker(
          latitude: sourceLatitude,
          longitude: sourceLongitude,
          id: "pickUp",
          descriptor: dropIcon!,
          rotation: 0.0);
      addMarker(
          latitude: destinationLatitude,
          longitude: destinationLongitude,
          id: "drop",
          descriptor: pickUpIcon!,
          rotation: 0.0);

      _addPolyLine(polylineCoordinates);
      // if (popupIndex.value == 0) popupIndex.value = 1;
      // await Constant()
      //     .getDriverData(mapModel.value, bookingModel.value, popupIndex);
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker(
      {required double? latitude,
      required double? longitude,
      required String id,
      required BitmapDescriptor descriptor,
      required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
        rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  addMarkerSetup() async {
    final Uint8List pickUpUint8List = await Constant()
        .getBytesFromAsset('assets/icon/ic_pick_up_map.png', 100);
    final Uint8List dropUint8List = await Constant()
        .getBytesFromAsset('assets/icon/ic_drop_in_map.png', 100);
    final Uint8List driverUint8List =
        await Constant().getBytesFromAsset('assets/icon/car_image.png', 50);

    pickUpIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
    dropIcon = BitmapDescriptor.fromBytes(dropUint8List);
    // driverIcon = BitmapDescriptor.fromBytes(driverUint8List);
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  _addPolyLine(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      color: AppThemData.blueLight,
      startCap: Cap.roundCap,
      width: 4,
    );
    polyLines[id] = polyline;
    updateCameraLocation(
        polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  sendLatLon(String lat, String lon) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCMTOKEN:: $fcmToken");
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
    if (fcmToken == null) {
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name.value = preferences.getString("name") ?? "";
    phoneNumber.value = preferences.getString("phone_number") ?? "";
    profilePic.value = preferences.getString("profile") ?? "";
    isLoading.value = true;
    userData = await FireStoreUtils.getUserProfileAPI();
    print("USERDATA::: $userData");
    if (userData != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString("token")!;

      isLoading.value = false;
      if (userData!.status != "Active") {
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
      name.value = userData!.name ?? '';
      phoneNumber.value =
          (userData!.countryCode ?? '91') + (userData!.phone ?? '****');
    }

    await Utils.getCurrentLocation();
    // updateCurrentLocation();
    update();
  }

  // Location location = Location();

  // updateCurrentLocation() async {
  //   PermissionStatus permissionStatus = await location.hasPermission();
  //   if (permissionStatus == PermissionStatus.granted) {
  //     //location.enableBackgroundMode(enable: true);
  //     location.changeSettings(
  //         accuracy: LocationAccuracy.high,
  //         distanceFilter:
  //             double.parse(Constant.driverLocationUpdate.toString()),
  //         interval: 2000);
  //     location.onLocationChanged.listen((locationData) {
  //       log("------>");
  //       log(locationData.toString());
  //       Constant.currentLocation = LocationLatLng(
  //           latitude: locationData.latitude, longitude: locationData.longitude);
  //       sendLatLon(locationData.latitude.toString(),
  //           locationData.longitude.toString());
  //     });
  //   } else {
  //     location.requestPermission().then((permissionStatus) {
  //       log("------>3");
  //       if (permissionStatus == PermissionStatus.granted) {
  //         location.enableBackgroundMode(enable: true);
  //         location.changeSettings(
  //             accuracy: LocationAccuracy.high,
  //             distanceFilter:
  //                 double.parse(Constant.driverLocationUpdate.toString()),
  //             interval: 2000);
  //         location.onLocationChanged.listen((locationData) async {
  //           Constant.currentLocation = LocationLatLng(
  //               latitude: locationData.latitude,
  //               longitude: locationData.longitude);
  //           log("------>4");
  //           sendLatLon(locationData.latitude.toString(),
  //               locationData.longitude.toString());

  //           // FireStoreUtils.getDriverUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
  //           //   DriveruserData driveruserData = value!;
  //           //   if (driveruserData.isOnline == true) {
  //           //     driveruserData.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
  //           //     driveruserData.rotation = locationData.heading;
  //           //     GeoFirePoint position = GeoFlutterFire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
  //           //
  //           //     driveruserData.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
  //           //
  //           //     FireStoreUtils.updateDriverUser(driveruserData);
  //           //   }
  //           // });
  //         });
  //       }
  //       log("------>5");
  //     });
  //     log("------>6");
  //   }
  //   isLoading.value = false;
  //   update();
  // }

  Future<void> logOutUser(
    BuildContext context,
  ) async {
    try {
      print('---logOutUser----function call-----');

      // Show loader
      ShowToastDialog.showLoader("Please wait".tr);

      // API call to logout endpoint
      final response = await http.post(
        Uri.parse(baseURL + logOutEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token': token}),
      );

      print('---logOutUser----token-----$token');

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('---logOutUser----response-----$responseData');

        if (responseData['msg'] != null) {
          final String msg = responseData['msg'];

          // Reset shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);

          // Navigate to Splash Screen
          Get.to(const LoginView());
          // Close loader
          ShowToastDialog.closeLoader();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        } else {
          // Handle missing message key
          throw Exception("Invalid response from server");
        }
      } else {
        // Handle non-200 status codes
        throw Exception(
            "Failed to logout, status code: ${response.statusCode}");
      }
    } catch (e) {
      print('-----logout-----error---$e');

      // Reset shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Navigate to Splash Screen
      Get.to(const LoginView());

      // Close loader
      ShowToastDialog.closeLoader();
    }
  }
}
