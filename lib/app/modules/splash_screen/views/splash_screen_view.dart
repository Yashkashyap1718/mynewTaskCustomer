import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:customer/theme/app_them_data.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends StatelessWidget {
   SplashScreenView({super.key});
  SplashScreenController controller = Get.put(SplashScreenController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
        init: SplashScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.black,
            body: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/splash_background.png"),
                      fit: BoxFit.fill)),
              // child: Center(
              //   child: Image.asset(
              //     "assets/images/taxi.png",
              //     scale: 9,
              //   ),
              // ),
            ),
          );
        });
  }
}
