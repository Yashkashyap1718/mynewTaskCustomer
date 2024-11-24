// ignore_for_file: unnecessary_overrides

import 'package:customer/app/api_models/ride_history_data.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:get/get.dart';

import '../../../../utils/fire_store_utils.dart';

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
  RxList<BookingModel> ongoingRides = <BookingModel>[].obs;
  RxList<BookingModel> completedRides = <BookingModel>[].obs;
  RxList<BookingModel> rejectedRides = <BookingModel>[].obs;

  getData({required bool isOngoingDataFetch, required bool isCompletedDataFetch, required bool isRejectedDataFetch}) async {
   if(isOngoingDataFetch){
     ongoingRides.value = (await FireStoreUtils.getOngoingRides())??[];
   }else if(isCompletedDataFetch){
      completedRides.value = await FireStoreUtils.getCompletedRides()??[];
   }else if(isRejectedDataFetch){
   rejectedRides.value = (await FireStoreUtils.getRejectedRides()) ??[];
   }else{

   }
    isLoading.value = false;
  }
}
