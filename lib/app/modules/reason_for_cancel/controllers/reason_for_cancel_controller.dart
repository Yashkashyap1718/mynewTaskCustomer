// ignore_for_file: unnecessary_overrides

import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constant_widgets/show_toast_dialog.dart';

class ReasonForCancelController extends GetxController {
  Rx<BookingModel> bookingModel = BookingModel().obs;
  Rx<TextEditingController> otherReasonController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      bookingModel.value = argumentData['bookingModel'];
    }
  }

  RxInt selectedIndex = 0.obs;

  List<dynamic> reasons = Constant.cancellationReason;

  Future<bool> cancelBooking(BookingModel bookingModels) async {
    BookingModel bookingModel = bookingModels;
    bookingModel.bookingStatus = BookingStatus.bookingCancelled;
    bookingModel.cancelledBy = FireStoreUtils.getCurrentUid();
    bookingModel.cancelledReason = reasons[selectedIndex.value] != "Other"
        ? reasons[selectedIndex.value].toString()
        : "${reasons[selectedIndex.value].toString()} : ${otherReasonController.value.text}";
    bool? isCancelled = await FireStoreUtils.setBookingCancel(bookingModel);
    return (isCancelled ?? false);
  }

  sendCancelRideNotification() async {
    String   fcmToken = await FirebaseMessaging.instance.getToken()??"";
    if(fcmToken==""){
      ShowToastDialog.showToast("FCM token null");
      return;
    }
    // DriverUserModel? receiverUserModel = await FireStoreUtils.getDriverUserProfile(bookingModel.value.driverId.toString());
    Map<String, dynamic> playLoad = <String, dynamic>{"bookingId": bookingModel.value.id};
    await SendNotification.sendOneNotification(
        type: "order",
        token: fcmToken.toString(),
        title: 'Ride Cancelled'.tr,
        body: 'Ride #${bookingModel.value.id.toString().substring(0, 4)} is cancelled by Customer',
        bookingId: bookingModel.value.id,
        driverId: bookingModel.value.driverId.toString(),
        senderId: FireStoreUtils.getCurrentUid(),
        payload: playLoad);
  }
}
