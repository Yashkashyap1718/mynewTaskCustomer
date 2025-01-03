// ignore_for_file: unnecessary_overrides

import 'package:customer/api_services.dart';
import 'package:customer/app/models/ride_cancel_reasons.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ReasonForCancelController extends GetxController {
  RxList<RideCancelResaons> bookingModel3 = <RideCancelResaons>[].obs;
  RideData? rideData;
  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    bookingModel3.value = await getRideNotes();
  }

  RxInt selectedIndex=0.obs;      
}
