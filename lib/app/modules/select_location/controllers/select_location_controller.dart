import 'dart:async';
import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/distance_model.dart';
import 'package:customer/app/models/location_lat_lng.dart';
import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/positions.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/database_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLocationController extends GetxController {
  FocusNode pickUpFocusNode = FocusNode();
  FocusNode dropFocusNode = FocusNode();
  TextEditingController dropLocationController = TextEditingController();
  TextEditingController pickupLocationController =
      TextEditingController(text: 'Current Location');
  LatLng? sourceLocation;
  LatLng? destination;
  Position? currentLocationPosition;
  GoogleMapController? mapController;
  RxBool isLoading = true.obs;
  RxInt popupIndex = 0.obs;
  RxInt selectVehicleTypeIndex = 0.obs;
  Rx<MapModel?> mapModel = MapModel().obs;
  Rx<UserModel?> userModel = UserModel().obs;
  Rx<BookingModel> bookingModel = BookingModel().obs;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  RxString selectedPaymentMethod = 'Cash'.obs;
  RxString couponCode = "Enter coupon code".obs;
  RxBool isCouponCode = false.obs;
  Rx<CouponModel> selectedCouponModel = CouponModel().obs;

  RxList<TaxModel> taxList = (Constant.taxList ?? []).obs;

  changeVehicleType(int index) {
    selectVehicleTypeIndex.value = index;
    bookingModel.value.vehicleType = Constant.vehicleTypeList![index];
    bookingModel.value.subTotal =
        amountShow(Constant.vehicleTypeList![index], mapModel.value!);
    if (bookingModel.value.coupon != null) {
      bookingModel.value.discount = applyCoupon().toString();
    }
    bookingModel.value = BookingModel.fromJson(bookingModel.value.toJson());
  }

  @override
  void onInit() {
    log('-----mapModel---$mapModel');
    getData();
    Constant().getDriverData();
    super.onInit();
  }

  getTax() async {
    await FireStoreUtils().getTaxList().then((value) {
      if (value != null) {
        Constant.taxList = value;
        taxList.value = value;
        print("===> ${Constant.taxList!.length}");
      }
    });
  }

  static Future<bool> updateCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    final String url = baseURL + currentLocationEndpoint;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    // Request body
    final Map<String, dynamic> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "fcmToken": "$token",
    };

    try {
      // HTTP PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'token': token.toString(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Check if the response status is OK
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true) {
          log("Location updated successfully: ${jsonResponse['msg']}");
          return true;
        } else {
          log("Failed to update location: ${jsonResponse['msg']}");
        }
      } else {
        log("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (error, stackTrace) {
      log('Failed to update current location: $error $stackTrace');
    }
    return false;
  }

  getData() async {
    currentLocationPosition = await Utils.getCurrentLocation();
    Constant.country = (await placemarkFromCoordinates(
                currentLocationPosition!.latitude,
                currentLocationPosition!.longitude))[0]
            .country ??
        'Unknown';
    getTax();
    sourceLocation = LatLng(
        currentLocationPosition!.latitude, currentLocationPosition!.longitude);
    await updateCurrentLocation(
        latitude: sourceLocation!.latitude,
        longitude: sourceLocation!.longitude);
    await addMarkerSetup();

    if (destination != null && sourceLocation != null) {
      getPolyline(
          sourceLatitude: sourceLocation!.latitude,
          sourceLongitude: sourceLocation!.longitude,
          destinationLatitude: destination!.latitude,
          destinationLongitude: destination!.longitude);
    } else {
      if (destination != null) {
        addMarker(
            latitude: destination!.latitude,
            longitude: destination!.longitude,
            id: "drop",
            descriptor: dropIcon!,
            rotation: 0.0);
        updateCameraLocation(destination!, destination!, mapController);
      } else {
        MarkerId markerId = const MarkerId("drop");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
        }
        log("==> ${markers.containsKey(markerId)}");
      }
      if (sourceLocation != null) {
        addMarker(
            latitude: sourceLocation!.latitude,
            longitude: sourceLocation!.longitude,
            id: "pickUp",
            descriptor: pickUpIcon!,
            rotation: 0.0);
        updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
      } else {
        MarkerId markerId = const MarkerId("pickUp");
        if (markers.containsKey(markerId)) {
          markers.removeWhere((key, value) => key == markerId);
          updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
        }
        log("==> ${markers.containsKey(markerId)}");
      }
    }
    dropFocusNode.requestFocus();
    isLoading.value = false;
  }

  setBookingData(bool isClear) async {
    DatabaseHelper db = DatabaseHelper();
    if (isClear) {
      bookingModel.value = BookingModel();
    } else {
      UserModel? user = await db.retrieveUserFromTable();
      bookingModel.value.customerId = user!.id;
      bookingModel.value.bookingStatus = BookingStatus.bookingPlaced;
      bookingModel.value.pickUpLocation = LocationLatLng(
          latitude: sourceLocation!.latitude,
          longitude: sourceLocation!.longitude);
      bookingModel.value.dropLocation = LocationLatLng(
          latitude: destination!.latitude, longitude: destination!.longitude);
      GeoFirePoint position = GeoFlutterFire().point(
          latitude: sourceLocation!.latitude,
          longitude: sourceLocation!.longitude);

      bookingModel.value.position =
          Positions(geoPoint: position.geoPoint, geohash: position.hash);

      bookingModel.value.distance = DistanceModel(
        distance: distanceCalculate(mapModel.value),
        distanceType: Constant.distanceType,
      );
      bookingModel.value.vehicleType =
          Constant.vehicleTypeList![selectVehicleTypeIndex.value];
      bookingModel.value.subTotal = amountShow(
          Constant.vehicleTypeList![selectVehicleTypeIndex.value],
          mapModel.value!);
      bookingModel.value.otp = Constant.getOTPCode();
      bookingModel.value.paymentType = Constant.paymentModel!.cash!.name;
      bookingModel.value.paymentStatus = false;
      bookingModel.value.taxList = taxList;
      bookingModel.value.adminCommission = Constant.adminCommission!;
      bookingModel.value = BookingModel.fromJson(bookingModel.value.toJson());
    }
  }

  updateData() async {
    // Check if both source and destination locations are set
    if (destination != null && sourceLocation != null) {
      // Fetch polyline and show loader
      getPolyline(
        sourceLatitude: sourceLocation!.latitude,
        sourceLongitude: sourceLocation!.longitude,
        destinationLatitude: destination!.latitude,
        destinationLongitude: destination!.longitude,
      );

      ShowToastDialog.showLoader("Please wait".tr);

      // Fetch distance and duration data
      mapModel.value =
          await Constant.getDurationDistance(sourceLocation!, destination!);

      if (mapModel.value != null) {
        // Update booking model with addresses
        bookingModel.value.dropLocationAddress =
            mapModel.value!.destinationAddresses!.first;
        bookingModel.value.pickUpLocationAddress =
            mapModel.value!.originAddresses!.first;
        bookingModel.value = BookingModel.fromJson(bookingModel.value.toJson());

        ShowToastDialog.closeLoader();
        log("--mapModel--Data : ${mapModel.value!.toJson()}");

        // Update popup index if necessary
        if (popupIndex.value == 0) popupIndex.value = 1;

        setBookingData(false);
      } else {
        ShowToastDialog.closeLoader();
        popupIndex.value = 0;
        ShowToastDialog.showToast(
            "Something went wrong!, Please select location again");
      }
    } else {
      // Handle cases when source or destination is null
      if (destination != null) {
        // Add drop marker
        addMarker(
          latitude: destination!.latitude,
          longitude: destination!.longitude,
          id: "drop",
          descriptor: dropIcon!,
          rotation: 0.0,
        );
        updateCameraLocation(destination!, destination!, mapController);
      } else {
        removeMarker("drop");
      }

      if (sourceLocation != null) {
        // Add pickup marker
        addMarker(
          latitude: sourceLocation!.latitude,
          longitude: sourceLocation!.longitude,
          id: "pickUp",
          descriptor: pickUpIcon!,
          rotation: 0.0,
        );
        updateCameraLocation(sourceLocation!, sourceLocation!, mapController);
      } else {
        removeMarker("pickUp");
      }
    }
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
    if (sourceLatitude != null &&
        sourceLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.mapAPIKey,
        request: PolylineRequest(
          origin: PointLatLng(sourceLatitude, sourceLongitude),
          destination: PointLatLng(destinationLatitude, destinationLongitude),
          mode: TravelMode.driving,
          wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );
      /*  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: Constant.mapAPIKey,
          request: PolylineRequest(
              origin: PointLatLng(sourceLatitude, sourceLongitude), destination: PointLatLng(destinationLatitude, destinationLongitude), mode: TravelMode.driving)
          // PointLatLng(sourceLatitude, sourceLongitude),
          // request:  PointLatLng(destinationLatitude, destinationLongitude),
          // travelMode: TravelMode.driving,
          );*/
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        log(result.errorMessage.toString());
      }

      addMarker(
          latitude: sourceLatitude,
          longitude: sourceLongitude,
          id: "pickUp",
          descriptor: pickUpIcon!,
          rotation: 0.0);
      addMarker(
          latitude: destinationLatitude,
          longitude: destinationLongitude,
          id: "drop",
          descriptor: dropIcon!,
          rotation: 0.0);

      _addPolyLine(polylineCoordinates);
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
    pickUpIcon = BitmapDescriptor.fromBytes(pickUpUint8List);
    dropIcon = BitmapDescriptor.fromBytes(dropUint8List);
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  _addPolyLine(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      color: AppThemData.primary400,
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

  String amountShow(VehicleTypeModel vehicleType, MapModel value) {
    if (Constant.distanceType == "Km") {
      var distance =
          (value.rows!.first.elements!.first.distance!.value!.toInt() / 1000);
      if (distance >
          double.parse(vehicleType.charges.fareMinimumChargesWithinKm)) {
        return Constant.amountCalculate(
                vehicleType.charges.farePerKm.toString(), distance.toString())
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      } else {
        return Constant.amountCalculate(
                vehicleType.charges.farMinimumCharges.toString(),
                distance.toString())
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    } else {
      var distance =
          (value.rows!.first.elements!.first.distance!.value!.toInt() /
              1609.34);
      if (distance >
          double.parse(vehicleType.charges.fareMinimumChargesWithinKm)) {
        return Constant.amountCalculate(
                vehicleType.charges.farePerKm.toString(), distance.toString())
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      } else {
        return Constant.amountCalculate(
                vehicleType.charges.farMinimumCharges.toString(),
                distance.toString())
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
  }

  String distanceCalculate(MapModel? value) {
    if (Constant.distanceType == "Km") {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() /
              1000)
          .toString();
    } else {
      return (value!.rows!.first.elements!.first.distance!.value!.toInt() /
              1609.34)
          .toString();
    }
  }

  double applyCoupon() {
    if (bookingModel.value.coupon != null) {
      if (bookingModel.value.coupon!.id != null) {
        if (bookingModel.value.coupon!.isFix == true) {
          return double.parse(bookingModel.value.coupon!.amount.toString());
        } else {
          return double.parse(bookingModel.value.subTotal ?? '0.0') *
              double.parse(bookingModel.value.coupon!.amount.toString()) /
              100;
        }
      } else {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }
}
