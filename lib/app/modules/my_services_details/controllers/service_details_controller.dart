import 'package:customer/api_services.dart';
import 'package:customer/app/models/service_list_modal.dart';
import 'package:get/get.dart';

class ServiceDetailsController extends GetxController {
  RxList<ServiceListModal> serviceList = <ServiceListModal>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  getData() async {
    serviceList.clear();
    serviceList.value = await getServiceList();
    print(serviceList.value);
  }
}
