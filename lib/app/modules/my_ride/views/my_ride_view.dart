import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/models/my_ride_model.dart';
import 'package:customer/app/modules/my_ride_details/controllers/my_ride_details_controller.dart';
import 'package:customer/app/modules/my_ride_details/views/my_ride_details_view.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/no_rides_view.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/my_ride_controller.dart';

class MyRideView extends StatelessWidget {
  const MyRideView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: MyRideController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Text("My Rides".tr),
            ),
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            // appBar: AppBarWithBorder(
            //   title: "My Rides".tr,
            //   bgColor: themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
            //   isUnderlineShow: false,
            // ),
            body: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      // color: Colors.grey.withOpacity(0.2),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RoundShapeButton(
                            title: "Ongoing".tr,
                            buttonColor: controller.selectedType.value == 0
                                ? AppThemData.primary400
                                : AppThemData.primary200,
                            buttonTextColor: Colors.grey,
                            onTap: () {
                              controller.selectedType.value = 0;
                            },
                            size: Size((Responsive.width(90, context) / 3), 38),
                            textSize: 8,
                          ),
                          RoundShapeButton(
                            title: "Completed".tr,
                            buttonColor: controller.selectedType.value == 1
                                ? AppThemData.primary400
                                : AppThemData.primary200,
                            buttonTextColor: Colors.grey,
                            onTap: () {
                              controller.selectedType.value = 1;
                            },
                            size: Size((Responsive.width(90, context) / 3), 38),
                            textSize: 8,
                          ),
                          RoundShapeButton(
                            title: "Cancelled".tr,
                            buttonColor: controller.selectedType.value == 2
                                ? AppThemData.primary400
                                : AppThemData.primary200,
                            buttonTextColor: Colors.grey,
                            onTap: () {
                              controller.selectedType.value = 2;
                            },
                            size: Size((Responsive.width(90, context) / 3), 38),
                            textSize: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async {
                    if (controller.selectedType.value == 0) {
                      await controller.getData(
                          isOngoingDataFetch: true,
                          isCompletedDataFetch: false,
                          isRejectedDataFetch: false);
                    } else if (controller.selectedType.value == 1) {
                      await controller.getData(
                          isOngoingDataFetch: false,
                          isCompletedDataFetch: true,
                          isRejectedDataFetch: false);
                    } else {
                      await controller.getData(
                          isOngoingDataFetch: false,
                          isCompletedDataFetch: false,
                          isRejectedDataFetch: true);
                    }
                  },
                  child: SizedBox(
                    height: Responsive.height(75, context),
                    child: Obx(
                      () => (controller.selectedType.value == 0
                              ? controller.ongoingRides.isNotEmpty
                              : controller.selectedType.value == 1
                                  ? controller.completedRides.isNotEmpty
                                  : controller.rejectedRides.isNotEmpty)
                          ? ListView.builder(
                              itemCount: controller.selectedType.value == 0
                                  ? controller.ongoingRides.length
                                  : controller.selectedType.value == 1
                                      ? controller.completedRides.length
                                      : controller.rejectedRides.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                RxBool isOpen = false.obs;
                                MyRideModel bookingModel =
                                    controller.selectedType.value == 0
                                        ? controller.ongoingRides[index]
                                        : controller.selectedType.value == 1
                                            ? controller.completedRides[index]
                                            : controller.rejectedRides[index];
                                return InkWell(
                                  onTap: () {
                                    MyRideDetailsController detailsController =
                                        Get.put(MyRideDetailsController());
                                    detailsController.bookingId.value =
                                        bookingModel.id ?? '';
                                    detailsController.bookingModel.value =
                                        bookingModel;
                                    Get.to(const MyRideDetailsView());
                                  },
                                  child: Container(
                                    width: Responsive.width(100, context),
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.all(16),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            isOpen.value = !isOpen.value;
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                DateFormat('EEE, MMM d, ' 'yy')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            bookingModel
                                                                .createdAt!)),
                                                style: GoogleFonts.inter(
                                                  color:
                                                      themeChange.isDarkTheme()
                                                          ? AppThemData.grey400
                                                          : AppThemData.grey500,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_right_sharp,
                                                color: themeChange.isDarkTheme()
                                                    ? AppThemData.grey400
                                                    : AppThemData.grey500,
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 60,
                                                width: 60,
                                                child: ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: bookingModel
                                                                .vehicle ==
                                                            null
                                                        ? Constant
                                                            .profileConstant
                                                        : "$imageBaseUrl${bookingModel.vehicle!.image}",
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Constant.loader(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        Image.asset(Constant
                                                            .userPlaceHolder),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      bookingModel
                                                              .driver?.name ??
                                                          bookingModel.vehicle
                                                              ?.vehicleNumber ??
                                                          "No Driver Assigned",
                                                      style: GoogleFonts.inter(
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemData.grey25
                                                            : AppThemData
                                                                .grey950,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      bookingModel
                                                              .vehicle?.name ??
                                                          "",
                                                      style: GoogleFonts.inter(
                                                        color: themeChange
                                                                .isDarkTheme()
                                                            ? AppThemData.grey25
                                                            : AppThemData
                                                                .grey950,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    bookingModel.fareAmount ??
                                                        "0",
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.inter(
                                                      color: themeChange
                                                              .isDarkTheme()
                                                          ? AppThemData.grey25
                                                          : AppThemData.grey950,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        bookingModel.vehicle
                                                                ?.vehicleType ??
                                                            "",
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: AppThemData
                                                              .primary400,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Obx(() => Visibility(
                                              visible: isOpen.value,
                                              child: PickDropPointView(
                                                  pickUpAddress: bookingModel
                                                          .pickupAddress ??
                                                      '',
                                                  dropAddress: bookingModel
                                                          .dropoffAddress ??
                                                      ''),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView(children: [
                              NoRidesView(themeChange: themeChange)
                            ]),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
