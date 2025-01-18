import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/my_ride_model.dart';
import 'package:customer/app/models/ride_cancel_reasons.dart';
import 'package:customer/app/models/service_list_modal.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/owner_support_ticket_modal.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/models/near_by_drivers.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/utils/my_notification_handler.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<NearbyDriversResponse?> setBooking(BookingModel bookingModel) async {
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
    // ignore: unnecessary_null_comparison
    "vehicle_type": (bookingModel.vehicleType!.title == null)
        ? ''
        : bookingModel.vehicleType!.title,
    "fare_amount":
        (bookingModel.subTotal == null) ? '' : bookingModel.subTotal.toString(),
    "duration_in_minutes": "50",
  };

  final response = await http.post(
    Uri.parse(baseURL + userRideSubmit),
    body: jsonEncode(map),
    headers: {"Content-Type": "application/json", "token": token},
  );

  NearbyDriversResponse nearbyDrivers;
  // print("RIDEBOOKING REQUST ${response.body}");  isma be krde
  if (response.statusCode == 200) {
    nearbyDrivers = NearbyDriversResponse.fromJson(jsonDecode(response.body));
    // return jsonDecode(response.body);
  } else if (response.statusCode == 404) {
    nearbyDrivers = NearbyDriversResponse(
        status: false,
        msg: "Failed to add ride",
        data: [],
        rideId: ""); // Initialize with default value
    log("Driver not found");
  } else {
    log("Failed to add ride:");
    nearbyDrivers = NearbyDriversResponse(
        status: false,
        msg: "Failed to add ride",
        data: [],
        rideId: ""); // Initialize with default value
  }

  if (nearbyDrivers.data.isEmpty) {
    nearbyDrivers = NearbyDriversResponse(
        status: false,
        msg: "Failed to add ride",
        data: [],
        rideId: ""); // Initialize with default value
    log("Driver not found");
  }

  return nearbyDrivers;
}

RideBooking? ride;

Stream<RideBooking?> checkRequest() async* {
  String status = "";
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

    // if (jsonDecode(response.body)["data"] == '[]' ||
    //     jsonDecode(response.body)["data"] == null) {
    //   lastRide = ride;
    //   yield lastRide; // {{ edit_1 }}
    // }

    if (response.statusCode == 200 &&
        jsonDecode(response.body)["data"] != '[]' &&
        jsonDecode(response.body)["data"] != null) {
      RideBooking listModel =
          RideBooking.fromJson(jsonDecode(response.body)["data"]);
      ride = listModel;
      log("listModel: ${listModel.toJson()}");

      if (status != listModel.status) {
        status = listModel.status;

        if (status == "cancelled") {
          MyNotificationHandler().showDefaultNotification("Ride Cancelled",
              "Ride #${listModel.id.toString().substring(0, 4)} is cancelled by Customer");
        } else if (status == "accepted") {
          MyNotificationHandler().showDefaultNotification("Ride Accepted",
              "Ride #${listModel.id.toString().substring(0, 4)} is accepted by Driver");
        } else if (status == "started") {
          MyNotificationHandler().showDefaultNotification("Ride Started",
              "Ride #${listModel.id.toString().substring(0, 4)} is started by Driver");
        } else if (status == "in_progress") {
          MyNotificationHandler().showDefaultNotification("Ride in Progress",
              "Ride #${listModel.id.toString().substring(0, 4)} is in progress");
        } else if (status == "completed") {
          MyNotificationHandler().showDefaultNotification("Ride Completed",
              "Ride #${listModel.id.toString().substring(0, 4)} is completed");
        }
      }

      yield listModel; // {{ edit_1 }}
    } else {
      yield null; // {{ edit_2 }}
    }
    await Future.delayed(Duration(
        seconds: 2)); // Delay for 5 seconds before making the next request
  }
}

Future<bool> cancelBooking(RideBooking bookingModels, String reason) async {
  bool? isCancelled = await setBookingCancel(bookingModels, reason);
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

Future<bool?> setBookingCancel(RideBooking bookingModel, String reason) async {
  ShowToastDialog.showLoader("Please wait");
  bool canceled = false;
  Map<String, Object> map = {"ride_id": bookingModel.id, "reason": reason};
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

Future<bool> sendTopicNotification({
  required String topic,
  required String title,
  required String body,
  Map<String, dynamic>? payload,
}) async {
  try {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AIzaSyCMRryPgY1DJOc7a7sp81Y88oBhmXkDLR8', // Replace with your FCM server key
      },
      body: jsonEncode({
        'to': '/topics/$topic',
        'notification': {
          'title': title,
          'body': body,
        },
        'data': payload ?? {},
      }),
    );

    if (response.statusCode == 200) {
      log('Topic notification sent successfully');
      return true;
    } else {
      log('Failed to send topic notification: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    log('Error sending topic notification: $e');
    return false;
  }
}

Future<List<BannerModel>> getBanners() async {
  List<BannerModel> bannerModel = [];
  final response = await http.get(
    Uri.parse(baseURL + bannerEndPoint),
    headers: {"Content-Type": "application/json", "token": token},
  );

  if (response.statusCode == 200) {
    bannerModel = List<BannerModel>.from(
      jsonDecode(response.body)['data'].map(
        (item) => BannerModel.fromJson(item),
      ),
    );
    // return jsonDecode(response.body);
  } else if (response.statusCode == 404) {
    log("banners not found");
    ShowToastDialog.closeLoader();
  } else {
    log("Failed to add banners:");
    ShowToastDialog.closeLoader();
  }

  return bannerModel;
}

Future<List<MyRideModel>> getRidesList(String api) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  Map<String, dynamic> payload = {"startValue": 0, "lastValue": 20};
  final http.Response response = await http.post(
    Uri.parse("$baseURL$api"),
    headers: {
      'Content-Type': 'application/json',
      "token": token.toString(),
    },
    body: jsonEncode(payload),
  );
  if (jsonDecode(response.body)["status"] == true &&
      response.statusCode == 200) {
    List<MyRideModel> rides = [];
    for (var ride in jsonDecode(response.body)["data"]) {
      rides.add(MyRideModel.fromJson(ride));
    }
    return rides;
  }
  return [];
}

Future<List<ServiceListModal>> getServiceList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  final http.Response response = await http.get(
    Uri.parse("$baseURL$serviceListEndPoint"),
    headers: {
      'Content-Type': 'application/json',
      "token": token.toString(),
    },
  );
  if (jsonDecode(response.body)["status"] == true &&
      response.statusCode == 200) {
    List<ServiceListModal> rides = [];
    for (var ride in jsonDecode(response.body)["data"]) {
      rides.add(ServiceListModal.fromJson(ride));
    }
    return rides;
  }
  return [];
}

Future<List<RideCancelResaons>> getRideNotes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  final http.Response response = await http.get(
    Uri.parse("$baseURL$rideNotesEndPoint"),
    headers: {
      'Content-Type': 'application/json',
      "token": token.toString(),
    },
  );
  if (jsonDecode(response.body)["status"] == true &&
      response.statusCode == 200) {
    List<RideCancelResaons> rides = [];
    for (var ride in jsonDecode(response.body)["data"]) {
      rides.add(RideCancelResaons.fromJson(ride));
    }
    return rides;
  }
  return [];
}

Future<List<SupportTicketDataModel>> getDriverSupportTickList() async {
  int inital = 0;
  int last = 20;

  String endPoint = getTicketList;

  Map<String, dynamic> params = {"startValue": inital, "lastValue": last};

  // String token = await Preferences.getToken();

  final response = await http.post(
    Uri.parse(baseURL + endPoint),
    headers: {"Content-Type": "application/json", "token": token},
    body: jsonEncode(params),
  );

  if (response.statusCode == 200 && jsonDecode(response.body)["status"]) {
    List<SupportTicketDataModel> list = List<SupportTicketDataModel>.from(
        jsonDecode(response.body)["data"]
            .map((e) => SupportTicketDataModel.fromJson(e)));

    return list;
  } else {
    return [];
  }
}

Future<Map<String, dynamic>> createSupportTicketAPI(
    Map<String, dynamic> params) async {
  String endPoint = createSupportTicket;
  params["title"] = "I am not getting any responder from customer1";

  final response = await http.post(
    Uri.parse(baseURL + endPoint),
    headers: {
      "Content-Type": "application/json",
      "token": token,
    },
    body: jsonEncode(params),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception(
        'Failed to create support ticket: ${response.reasonPhrase}');
  }
}
