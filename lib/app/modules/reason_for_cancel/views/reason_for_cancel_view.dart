import 'package:customer/api_services.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/reason_for_cancel/controllers/reason_for_cancel_controller.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReasonForCancelView extends StatelessWidget {
  final RideBooking rideData;

  const ReasonForCancelView({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<ReasonForCancelController>(
      init: ReasonForCancelController(),
      builder: (controller) => Scaffold(
        backgroundColor:
            themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
        appBar: AppBarWithBorder(
            title: "Reasons for Canceling Ride".tr,
            bgColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundShapeButton(
                title: "Cancel",
                buttonColor: AppThemData.grey50,
                buttonTextColor: AppThemData.black,
                onTap: () {
                  Get.back();
                },
                size: Size(Responsive.width(45, context), 52),
              ),
              RoundShapeButton(
                title: "Continue",
                buttonColor: AppThemData.primary400,
                buttonTextColor: AppThemData.black,
                onTap: () async {
                  bool isCancelled = await cancelBooking(
                      rideData,
                      controller
                          .bookingModel3[controller.selectedIndex.value].reason
                          .toString());
                  if (isCancelled) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return CustomDialogBox(
                          title: "Your ride is successfully cancelled.".tr,
                          descriptions:
                              "We hope to serve you better next time.".tr,
                          img: Image.asset(
                            "assets/icon/ic_green_right.png",
                            height: 58,
                            width: 58,
                          ),
                          positiveClick: () async {
                            sendCancelRideNotification(rideData);
                            ShowToastDialog.showToast(
                                "Ride Cancelled Successfully..");

                            Get.offAll(const HomeView());
                            Get.toNamed(Routes.HOME);
                          },
                          negativeClick: () {
                            // Navigator.pop(context);
                            // Get.back();
                            Get.offAll(const HomeView());
                            Get.toNamed(Routes.HOME);
                          },
                          positiveString: "Back to Home".tr,
                          negativeString: "Cancel".tr,
                          themeChange: themeChange,
                          negativeButtonColor: AppThemData.grey50,
                          negativeButtonTextColor: AppThemData.grey950,
                        );
                      },
                    );
                  } else {
                    ShowToastDialog.showToast("Something went wrong!");
                  }
                },
                size: Size(Responsive.width(45, context), 52),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Column(
                children: [
                  if (controller.bookingModel3.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Obx(
                          () => Column(
                            children: [
                              RadioListTile(
                                value: index,
                                contentPadding: EdgeInsets.zero,
                                groupValue: controller.selectedIndex.value,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                activeColor: AppThemData.primary400,
                                onChanged: (ind) {
                                  controller.selectedIndex.value = ind ?? 0;
                                },
                                title: Text(
                                  controller.bookingModel3[index].reason
                                      .toString(),
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme()
                                        ? AppThemData.grey25
                                        : AppThemData.grey950,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (index !=
                                  (controller.bookingModel3.length - 1))
                                const Divider()
                            ],
                          ),
                        );
                      },
                      itemCount: controller.bookingModel3.length,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
