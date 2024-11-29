import 'package:get/get.dart';

import '../controllers/login_email_verification_controller.dart';

class LoginEmailVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginEmailVerificationController());
  }
}
