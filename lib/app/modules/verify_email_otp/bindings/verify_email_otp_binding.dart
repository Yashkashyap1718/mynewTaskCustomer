import 'package:get/get.dart';

import '../controllers/verify_email_otp_controller.dart';

class VerifyEmailOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyEmailOtpController());
  }
}
