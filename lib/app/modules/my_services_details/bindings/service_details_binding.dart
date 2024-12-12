import 'package:customer/app/modules/my_services_details/controllers/service_details_controller.dart';
import 'package:get/get.dart';

class ServiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceDetailsController>(() => ServiceDetailsController());
  }
}

