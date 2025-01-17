import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

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
import 'package:customer/models/ride_booking.dart';
import 'package:customer/theme/app_them_data.dart';
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
  TextEditingController pickupLocationController = TextEditingController();
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

  BitmapDescriptor? driverIcon;
  RideBooking? rideBooking;

  String? distance;

  changeVehicleType(int index) {
    selectVehicleTypeIndex.value = index;
    bookingModel.value.vehicleType = Constant.vehicleTypeList![index];
    bookingModel.value.subTotal =
        Constant.vehicleTypeList![index].charges.farMinimumCharges;
    if (bookingModel.value.coupon != null) {
      bookingModel.value.discount = applyCoupon().toString();
    }
    bookingModel.value = BookingModel.fromJson(bookingModel.value.toJson());
  }

  @override
  void onInit() {
    log('-----mapModel---$mapModel');

    rideBooking = Get.arguments;
    log("bookingModel.value: ${bookingModel.value.toJson()}");

    try {
      sourceLocation = LatLng(rideBooking!.pickupLocation.coordinates[0],
          rideBooking!.pickupLocation.coordinates[1]);
      destination = LatLng(rideBooking!.dropoffLocation.coordinates[0],
          rideBooking!.dropoffLocation.coordinates[1]);

      bookingModel.value = BookingModel(
          id: rideBooking?.id,
          pickUpLocation: LocationLatLng(
              latitude: rideBooking?.pickupLocation.coordinates[1] ?? 0,
              longitude: rideBooking?.pickupLocation.coordinates[0] ?? 0),
          dropLocation: LocationLatLng(
              latitude: rideBooking?.dropoffLocation.coordinates[1] ?? 0,
              longitude: rideBooking?.dropoffLocation.coordinates[0] ?? 0),
          pickUpLocationAddress: rideBooking?.pickupAddress,
          dropLocationAddress: rideBooking?.dropoffAddress,
          paymentType: rideBooking?.paymentMode,
          otp: rideBooking?.otp,
          bookingStatus: rideBooking?.status,
          driverId: rideBooking?.driver.id,
          customerId: rideBooking?.passenger.id,
          subTotal: rideBooking?.fareAmount,
          vehicleType: rideBooking?.vehicleType,
          distance: DistanceModel(
            distance: rideBooking?.distance,
            distanceType: Constant.distanceType,
          ),
          // createAt: rideBooking?.createdAt != null ? timestamp.Timestamp.fromDate(rideBooking!.createdAt as DateTime) : null,
          // updateAt: rideBooking?.endTime != null ? timestamp.Timestamp.fromDate(rideBooking!.createdAt as DateTime) : null,
          // bookingTime: rideBooking?.startTime != null ? timestamp.Timestamp.fromDate(rideBooking!.createdAt as DateTime) : null,
          // pickupTime: rideBooking?.startTime != null ? timestamp.Timestamp.fromDate(rideBooking!.createdAt as DateTime) : null,
          // dropTime: rideBooking?.endTime != null ? timestamp.Timestamp.fromDate(rideBooking!.createdAt as DateTime) : null,
          paymentStatus: rideBooking?.paymentStatus == "cash",
          rejectedDriverId: [],
          taxList: [],
          position: null,
          coupon: null,
          adminCommission: null,
          cancelledBy: null,
          cancelledReason: null,
          discount: "0");

      popupIndex.value = 3;
    } catch (e) {}

    getData();

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
    token = prefs.getString("token") ?? "";

    // Request body
    final Map<String, dynamic> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "fcmToken": token,
    };
    // Constant().getDriverData(mapModel.value, bookingModel.value);
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
            descriptor: pickUpIcon!,
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
            descriptor: dropIcon!,
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
    // await Constant()
    //     .getDriverData(mapModel.value, bookingModel.value, popupIndex);
    // await Constant().getDriverData(mapModel.value, bookingModel.value);
    bookingModel.value.dropLocation?.latitude = destination!.latitude;
    bookingModel.value.dropLocation?.longitude = destination!.longitude;
    bookingModel.value.pickUpLocation?.latitude = sourceLocation!.latitude;
    bookingModel.value.pickUpLocation?.longitude = sourceLocation!.longitude;

    dropFocusNode.requestFocus();
    isLoading.value = false;
  }

  setBookingData(bool isClear) async {
    if (isClear) {
      bookingModel.value = BookingModel();
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("id") ?? "";

      bookingModel.value.dropLocation?.latitude = destination!.latitude;
      bookingModel.value.dropLocation?.longitude = destination!.longitude;
      bookingModel.value.pickUpLocation?.latitude = sourceLocation!.latitude;
      bookingModel.value.pickUpLocation?.longitude = sourceLocation!.longitude;

      bool isDone = await Constant()
          .getDriverData(mapModel.value, bookingModel.value, popupIndex)
          .then((onValue) {
        if (onValue == false) setBookingData(false);

        bookingModel.value.customerId = userId;
        bookingModel.value.bookingStatus = BookingStatus.bookingPlaced;
        bookingModel.value.pickUpLocation = LocationLatLng(
            latitude: sourceLocation!.latitude,
            longitude: sourceLocation!.longitude);
        bookingModel.value.dropLocation = LocationLatLng(
            latitude: destination!.latitude, longitude: destination!.longitude);
        GeoFirePoint position = GeoFlutterFire().point(
            latitude: sourceLocation!.latitude,
            longitude: sourceLocation!.longitude);

        distance = mapModel.value?.rows?.first.elements?.first.distance?.text
            .toString();

        bookingModel.value.position =
            Positions(geoPoint: position.geoPoint, geohash: position.hash);

        bookingModel.value.distance = DistanceModel(
          distance: distanceCalculate(mapModel.value),
          distanceType: Constant.distanceType,
        );
        bookingModel.value.vehicleType =
            Constant.vehicleTypeList![selectVehicleTypeIndex.value];
        bookingModel.value.subTotal = Constant
            .vehicleTypeList![selectVehicleTypeIndex.value]
            .charges
            .farMinimumCharges;
        bookingModel.value.otp = Constant.getOTPCode();
        bookingModel.value.paymentType = "Cash";
        bookingModel.value.paymentStatus = false;
        bookingModel.value.taxList = [];
        bookingModel.value = BookingModel.fromJson(bookingModel.value.toJson());

        return true;
      });
    }
  }

  updateData() async {
    log("--mapModel--Data : ${mapModel.value!.toJson()}");
    log("--destination--sourceLocation : $destination");
    log("--sourceLocation--sourceLocation : $sourceLocation");

    // Check if both source and destination locations are set
    if (destination != null && sourceLocation != null) {
      // Fetch polyline and show loader
      getPolyline(
        sourceLatitude: sourceLocation!.latitude,
        sourceLongitude: sourceLocation!.longitude,
        destinationLatitude: destination!.latitude,
        destinationLongitude: destination!.longitude,
      );

      // Animate camera to show both points
      await animateCameraToLocation(sourceLocation!, destination!);

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

        setBookingData(false);
      } else {
        ShowToastDialog.closeLoader();
        popupIndex.value = 0;
        ShowToastDialog.showToast(
            "Something went wrong!, Please select location again");
      }
    } else {
      // Handle single point cases
      if (destination != null) {
        addMarker(
          latitude: destination!.latitude,
          longitude: destination!.longitude,
          id: "drop",
          descriptor: pickUpIcon!,
          rotation: 0.0,
        );
        // Animate to destination
        await mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(destination!, 15),
        );
      } else {
        removeMarker("drop");
      }

      if (sourceLocation != null) {
        addMarker(
          latitude: sourceLocation!.latitude,
          longitude: sourceLocation!.longitude,
          id: "pickUp",
          descriptor: dropIcon!,
          rotation: 0.0,
        );
        // Animate to source
        await mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(sourceLocation!, 15),
        );
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
    driverIcon = BitmapDescriptor.fromBytes(driverUint8List);
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

  String amountShow(VehicleTypeModel vehicleType, MapModel value) {
    try {
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
    } catch (r) {
      print("------ amout show $r");
      return "100";
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

  Future<void> animateCameraToLocation(LatLng start, LatLng end) async {
    if (mapController == null) return;

    // Calculate the bounds that include both points
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        math.min(start.latitude, end.latitude),
        math.min(start.longitude, end.longitude),
      ),
      northeast: LatLng(
        math.max(start.latitude, end.latitude),
        math.max(start.longitude, end.longitude),
      ),
    );

    // Add padding to the bounds
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);

    try {
      await mapController!.animateCamera(cameraUpdate);
    } catch (e) {
      log("Error animating camera: $e");
    }
  }
}
