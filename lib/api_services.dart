import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:http/http.dart' as http;

Future<bool?> setBooking(BookingModel bookingModel) async {
  bool isAdded = false;
  // print("BookingModelJSONN :: ${jsonEncode(bookingModel.pickUpLocation)}");
  Map<String, dynamic> map = {
    "pickup_location": {
      "type": "Point",
      "coordinates": [
        bookingModel.pickUpLocation!.latitude,
        bookingModel.pickUpLocation!.longitude
      ]
    },
    "pickup_address": bookingModel.pickUpLocationAddress ?? '',
    "dropoff_location": {
      "type": "Point",
      "coordinates": [
        bookingModel.dropLocation!.latitude,
        bookingModel.dropLocation!.longitude
      ]
    },
    "dropoff_address": bookingModel.dropLocationAddress,
    "distance": 4.2,
    // "distance": double.tryParse(bookingModel.distance?.distance ?? '0'),
    "vehicle_type": (bookingModel.vehicleType!.title == null)
        ? ''
        : bookingModel.vehicleType!.title,
    "fare_amount": (bookingModel.subTotal == null) ? '' : "40",
    "duration_in_minutes": "50",
  };

  final response = await http.post(
    Uri.parse(baseURL + userRideSubmit),
    body: jsonEncode(map),
    headers: {"Content-Type": "application/json", "token": token},
  );

  // print("RIDEBOOKING REQUST ${response.body}");  isma be krde
  if (response.statusCode == 200) {
    isAdded = true;
    // return jsonDecode(response.body);
  } else if (response.statusCode == 404) {
    log("Driver not found");
    isAdded = false;
  } else {
    log("Failed to add ride:");
    isAdded = false;
  }
  return isAdded;
}

Stream<RideBooking?> checkRequest() async* {
  while (true) {
    final Map<String, dynamic> body = {"startValue": 0, "lastValue": 10};

    final response = await http.get(
      Uri.parse(baseURL + realtimeRequest),
      // body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json",
        "token": token,
      },
    );
    if (response.statusCode == 200 &&
        jsonDecode(response.body)["data"] != '[]') {
      RideBooking listModel =
          RideBooking.fromJson(jsonDecode(response.body)["data"]);
      yield listModel; // {{ edit_1 }}
    } else {
      yield null; // {{ edit_2 }}
    }
    await Future.delayed(Duration(
        seconds: 5)); // Delay for 5 seconds before making the next request
  }
}

Future<bool> cancelBooking(RideBooking bookingModels) async {
  bool? isCancelled = await setBookingCancel(bookingModels);
  return (isCancelled ?? false);
}

sendCancelRideNotification(RideBooking rideData) async {
  String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
  if (fcmToken == "") {
    ShowToastDialog.showToast("FCM token null");
    return;
  }
  // DriverUserModel? receiverUserModel = await FireStoreUtils.getDriverUserProfile(bookingModel.value.driverId.toString());
  Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": 'rideData.'};
  // await SendNotification.sendOneNotification(
  //     type: "order",
  //     token: fcmToken.toString(),
  //     title: 'Ride Cancelled',
  //     body:
  //         'Ride #${rideData!.id.toString().substring(0, 4)} is cancelled by Customer',
  //     bookingId: rideData.,
  //     driverId: rideData!.driverId,
  //     senderId: rideData!.passengerId,
  //     payload: playLoad);
}

Future<bool?> setBookingCancel(RideBooking bookingModel) async {
  ShowToastDialog.showLoader("Please wait");
  bool canceled = false;
  Map<String, Object> map = {"ride_id": bookingModel.id};
  final response = await http.put(
    Uri.parse(baseURL + userRideCanceled),
    body: jsonEncode(map),
    headers: {"Content-Type": "application/json", "token": token},
  );
  if (response.statusCode == 200) {
    canceled = true;
    ShowToastDialog.closeLoader();
    // return jsonDecode(response.body);
  } else if (response.statusCode == 404) {
    log("Driver not found");
    canceled = false;
    ShowToastDialog.closeLoader();
  } else {
    log("Failed to add ride:");
    canceled = false;
    ShowToastDialog.closeLoader();
  }

  return canceled;
}
