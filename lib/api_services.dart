import 'dart:convert';
import 'dart:developer';

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/utils/preferences.dart';

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
    body: jsonEncode({
      "pickup_location": {
        "type": "Point",
        "coordinates": [28.6280, 77.3649]
      },
      "pickup_address": "Noida Sector 62, UP",
      "dropoff_location": {
        "type": "Point",
        "coordinates": [28.6190, 77.0311]
      },
      "dropoff_address": "Dwarka More Delhi",
      "distance": 32.63,
      "vehicle_type": "suv",
      "fare_amount": "748.79",
      "duration_in_minutes": "48.95"
    }),
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
    if (response.statusCode == 200 && jsonDecode(response.body)["status"]) {
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
