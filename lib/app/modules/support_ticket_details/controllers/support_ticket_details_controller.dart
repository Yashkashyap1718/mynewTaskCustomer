import 'dart:developer';

import 'package:customer/app/owner_support_ticket_modal.dart';
import 'package:get/get.dart';

class SupportTicketDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<SupportTicketDataModel> supportTicketModel =
      SupportTicketDataModel(userId: UserId()).obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      supportTicketModel.value = argumentData["supportTicket"];
    }
    log(supportTicketModel.value.toString());
    isLoading.value = false;
  }
}
