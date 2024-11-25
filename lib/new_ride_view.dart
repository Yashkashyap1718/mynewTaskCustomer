import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant_widgets/custom_dialog_box.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewRideView extends StatelessWidget {
  final RideBooking? bookingModel;

  const NewRideView({super.key, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InkWell(
      onTap: () {
        // BookingDetailsController detailsController =
        //     Get.put(BookingDetailsController());
        // detailsController.bookingId.value = bookingModel!.id ?? '';
        // detailsController.bookingModel.value = bookingModel!;
        // Get.to(() => const BookingDetailsView());
      },
      child: Container(
        // width: Responsive.width(100, context),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey800
                    : AppThemData.grey100),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            PickDropPointView(
                pickUpAddress: bookingModel == null
                    ? ""
                    : bookingModel!.pickupAddress ?? '',
                dropAddress: bookingModel == null
                    ? ""
                    : bookingModel!.dropoffAddress ?? ''),
            // if ((bookingModel!.status ?? '') == BookingStatus.bookingPlaced &&
            //     !bookingModel!.!.contains(FireStoreUtils.getCurrentUid())) ...{

            if ((bookingModel!.status ?? '') ==
                BookingStatus.bookingRequested) ...{
              const SizedBox(height: 16),
              RoundShapeButton(
                title: "Cancel Ride",
                buttonColor: AppThemData.danger500,
                buttonTextColor: AppThemData.white,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialogBox(
                            themeChange: themeChange,
                            title: "Cancel Ride".tr,
                            negativeButtonColor: themeChange.isDarkTheme()
                                ? AppThemData.grey950
                                : AppThemData.grey50,
                            negativeButtonTextColor: themeChange.isDarkTheme()
                                ? AppThemData.grey50
                                : AppThemData.grey950,
                            positiveButtonColor: AppThemData.danger500,
                            positiveButtonTextColor: AppThemData.grey25,
                            descriptions:
                                "Are you sure you want cancel this ride?".tr,
                            positiveString: "Cancel Ride".tr,
                            negativeString: "Cancel".tr,
                            positiveClick: () async {
                              Navigator.pop(context);
                              // bool value =
                              //     await cancelRide(bookingModel!.rideId!);

                              // if (value == true) {
                              //   // ShowToastDialog.showToast(
                              //   //     "Ride cancelled successfully!");

                              //   Navigator.pop(context);
                              // } else {
                              //   ShowToastDialog.showToast(
                              //       "Something went wrong!");
                              //   Navigator.pop(context);
                              // }
                            },
                            negativeClick: () {
                              Navigator.pop(context);
                            },
                            img: Image.asset(
                              "assets/icon/ic_close.png",
                              height: 58,
                              width: 58,
                            ));
                      });
                },
                size: Size(Responsive.width(40, context), 42),
              ),
            },
            if ((bookingModel!.status ?? '') ==
                BookingStatus.bookingAccepted) ...{
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RoundShapeButton(
                    title: "Cancel Ride",
                    buttonColor: themeChange.isDarkTheme()
                        ? AppThemData.grey900
                        : AppThemData.grey50,
                    buttonTextColor: themeChange.isDarkTheme()
                        ? AppThemData.white
                        : AppThemData.black,
                    onTap: () {
                      // Get.to(() => ReasonForCancelView(
                      //       bookingModel: ,
                      //     ));
                    },
                    size: Size(Responsive.width(40, context), 42),
                  ),
                ],
              )
            }
          ],
        ),
      ),
    );
  }
}
