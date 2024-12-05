// ignore_for_file: unnecessary_overrides

import 'dart:convert';

import 'package:customer/app/models/my_ride_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyRideController extends GetxController {
  var selectedType = 0.obs;

  @override
  void onInit() {
    getData(
        isOngoingDataFetch: true,
        isCompletedDataFetch: true,
        isRejectedDataFetch: true);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  RxBool isLoading = true.obs;
  RxList<MyRideModel> ongoingRides = <MyRideModel>[].obs;
  RxList<MyRideModel> completedRides = <MyRideModel>[].obs;
  RxList<MyRideModel> rejectedRides = <MyRideModel>[].obs;

  getData(
      {required bool isOngoingDataFetch,
      required bool isCompletedDataFetch,
      required bool isRejectedDataFetch}) async {
    if (isOngoingDataFetch) {
      ongoingRides.value = (await getRidesList(ongoingRidesEndpoint));
    }
    if (isCompletedDataFetch) {
      completedRides.value = (await getRidesList(completedRidesEndpoint));
    }
    if (isRejectedDataFetch) {
      rejectedRides.value = (await getRidesList(rejectedRidesEndpoint));
    }
    isLoading.value = false;
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
}
