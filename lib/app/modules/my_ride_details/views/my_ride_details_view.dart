import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/app/modules/my_ride_details/views/widgets/payment_dialog_view.dart';
import 'package:customer/app/modules/payment_method/views/widgets/price_row_view.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/title_view.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/my_ride_details_controller.dart';

class MyRideDetailsView extends GetView<MyRideDetailsController> {
  const MyRideDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
        init: MyRideDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            appBar: AppBarWithBorder(
              title: "Ride Details".tr,
              bgColor: themeChange.isDarkTheme()
                  ? AppThemData.black
                  : AppThemData.white,
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () async {
                        if (controller.bookingModel.value.paymentStatus !=
                                "cash" &&
                            controller.bookingModel.value.status == "ongoing") {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            isDismissible: true,
                            enableDrag: true,
                            constraints: BoxConstraints(
                                maxHeight: Responsive.height(90, context),
                                maxWidth: Responsive.width(100, context)),
                            builder: (BuildContext context) {
                              return const PaymentDialogView();
                            },
                          );
                        }
                      },
                      child: Obx(
                        () => Container(
                          width: Responsive.width(100, context),
                          height: 56,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: themeChange.isDarkTheme()
                                      ? AppThemData.grey800
                                      : AppThemData.grey100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(() {
                                String paymentMethod =
                                    controller.selectedPaymentMethod.value;
                                return paymentMethod == "cash"
                                    ? SvgPicture.asset(
                                        "assets/icon/ic_cash.svg")
                                    : SvgPicture.asset(
                                        "assets/icon/ic_wallet.svg");
                              }),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.selectedPaymentMethod.value
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await controller.getBookingDetails();
              },
              child: FutureBuilder(
                future: controller.getBookingDetails(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Ride Status'.tr,
                                  style: GoogleFonts.inter(
                                    color: themeChange.isDarkTheme()
                                        ? AppThemData.grey25
                                        : AppThemData.grey950,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Obx(() {
                                return Text(
                                  controller.bookingModel.value.status ?? '',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: AppThemData.primary400,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Visibility(
                            visible: controller.bookingModel.value.status ==
                                "accepted",
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Your OTP for Ride'.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme()
                                          ? AppThemData.grey25
                                          : AppThemData.grey950,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  controller.bookingModel.value.otp ?? '',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    color: AppThemData.primary400,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                          TitleView(
                              titleText: 'Cab Details'.tr,
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12)),
                          Container(
                            width: Responsive.width(100, context),
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
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: CachedNetworkImage(
                                        imageUrl: controller.bookingModel.value
                                                    .vehicle ==
                                                null
                                            ? Constant.profileConstant
                                            : "$imageBaseUrl${controller.bookingModel.value.vehicle!.image}",
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            Constant.loader(),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                              Constant.userPlaceHolder,
                                              fit: BoxFit.cover,
                                            )),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller.bookingModel.value.driver
                                                  ?.name ??
                                              controller.bookingModel.value
                                                  .vehicle?.name ??
                                              'No Driver Assigned',
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme()
                                                ? AppThemData.grey25
                                                : AppThemData.grey950,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          controller.bookingModel.value.vehicle
                                                  ?.vehicleNumber ??
                                              controller.bookingModel.value
                                                  .vehicle?.vehicleType ??
                                              '',
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme()
                                                ? AppThemData.grey25
                                                : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Constant.amountToShow(
                                            amount: controller
                                                .bookingModel.value.fareAmount
                                                .toString()),
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              "assets/icon/ic_multi_person.svg"),
                                          const SizedBox(width: 6),
                                          Text(
                                            controller.bookingModel.value
                                                        .vehicle ==
                                                    null
                                                ? ""
                                                : controller.bookingModel.value
                                                    .vehicle!.vehicleType,
                                            style: GoogleFonts.inter(
                                              color: AppThemData.primary400,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // if (controller.bookingModel.value.status !=
                          //     "placed") ...{
                          //   FutureBuilder<DriverUserModel?>(
                          //       future: FireStoreUtils.getDriverUserProfile(
                          //           controller.bookingModel.value.id ?? ''),
                          //       builder: (context, snapshot) {
                          //         if (!snapshot.hasData) {
                          //           return Container();
                          //         }
                          //         DriverUserModel driverUserModel =
                          //             snapshot.data ?? DriverUserModel();
                          //         return Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             TitleView(
                          //                 titleText: 'Driver Details'.tr,
                          //                 padding: const EdgeInsets.fromLTRB(
                          //                     0, 0, 0, 12)),
                          //             Container(
                          //               width: Responsive.width(100, context),
                          //               padding: const EdgeInsets.all(16),
                          //               decoration: ShapeDecoration(
                          //                 shape: RoundedRectangleBorder(
                          //                   side: BorderSide(
                          //                       width: 1,
                          //                       color: themeChange.isDarkTheme()
                          //                           ? AppThemData.grey800
                          //                           : AppThemData.grey100),
                          //                   borderRadius:
                          //                       BorderRadius.circular(12),
                          //                 ),
                          //               ),
                          //               child: Row(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.center,
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.center,
                          //                 children: [
                          //                   Container(
                          //                     width: 44,
                          //                     height: 44,
                          //                     margin: const EdgeInsets.only(
                          //                         right: 10),
                          //                     clipBehavior: Clip.antiAlias,
                          //                     decoration: ShapeDecoration(
                          //                       color: themeChange.isDarkTheme()
                          //                           ? AppThemData.grey950
                          //                           : AppThemData.white,
                          //                       shape: RoundedRectangleBorder(
                          //                         borderRadius:
                          //                             BorderRadius.circular(
                          //                                 200),
                          //                       ),
                          //                       image: DecorationImage(
                          //                         image: NetworkImage(driverUserModel
                          //                                     .profilePic !=
                          //                                 null
                          //                             ? driverUserModel
                          //                                     .profilePic!
                          //                                     .isNotEmpty
                          //                                 ? driverUserModel
                          //                                         .profilePic ??
                          //                                     Constant
                          //                                         .profileConstant
                          //                                 : Constant
                          //                                     .profileConstant
                          //                             : Constant
                          //                                 .profileConstant),
                          //                         fit: BoxFit.fill,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                   Expanded(
                          //                     child: Column(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.start,
                          //                       crossAxisAlignment:
                          //                           CrossAxisAlignment.start,
                          //                       mainAxisSize: MainAxisSize.min,
                          //                       children: [
                          //                         Text(
                          //                           driverUserModel.fullName ??
                          //                               '',
                          //                           style: GoogleFonts.inter(
                          //                             color: themeChange
                          //                                     .isDarkTheme()
                          //                                 ? AppThemData.grey25
                          //                                 : AppThemData.grey950,
                          //                             fontSize: 16,
                          //                             fontWeight:
                          //                                 FontWeight.w600,
                          //                           ),
                          //                         ),
                          //                         Row(
                          //                           children: [
                          //                             const Icon(
                          //                                 Icons
                          //                                     .star_rate_rounded,
                          //                                 color: AppThemData
                          //                                     .warning500),
                          //                             Text(
                          //                               Constant.calculateReview(
                          //                                       reviewCount:
                          //                                           driverUserModel
                          //                                               .reviewsCount,
                          //                                       reviewSum:
                          //                                           driverUserModel
                          //                                               .reviewsSum)
                          //                                   .toString(),
                          //                               // driverUserModel.reviewsSum ?? '0.0',
                          //                               style:
                          //                                   GoogleFonts.inter(
                          //                                 color: themeChange
                          //                                         .isDarkTheme()
                          //                                     ? AppThemData
                          //                                         .white
                          //                                     : AppThemData
                          //                                         .black,
                          //                                 fontSize: 14,
                          //                                 fontWeight:
                          //                                     FontWeight.w400,
                          //                               ),
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                   // InkWell(
                          //                   //     onTap: () {
                          //                   //       Get.to(ChatScreenView(
                          //                   //         :
                          //                   //             driverUserModel.id ??
                          //                   //                 '',
                          //                   //       ));
                          //                   //     },
                          //                   //     child: SvgPicture.asset(
                          //                   //         "assets/icon/ic_message.svg")),
                          //                   // const SizedBox(width: 12),
                          //                   // InkWell(
                          //                   //     onTap: () {
                          //                   //       Constant().launchCall(
                          //                   //           "${driverUserModel.countryCode}${driverUserModel.phoneNumber}");
                          //                   //     },
                          //                   //     child: SvgPicture.asset(
                          //                   //         "assets/icon/ic_phone.svg"))
                          //                 ],
                          //               ),
                          //             ),
                          //             const SizedBox(
                          //               height: 16,
                          //             )
                          //           ],
                          //         );
                          //       })
                          // },
                          PickDropPointView(
                            pickUpAddress:
                                controller.bookingModel.value.pickupAddress ??
                                    '',
                            dropAddress:
                                controller.bookingModel.value.dropoffAddress ??
                                    '',
                          ),
                          TitleView(
                              titleText: 'Ride Details'.tr,
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 12)),
                          Container(
                            width: Responsive.width(100, context),
                            padding: const EdgeInsets.all(16),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/ic_calendar.svg",
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                          themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Date'.tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      controller.bookingModel.value.startTime ==
                                              null
                                          ? ""
                                          : controller
                                                  .bookingModel.value.startTime!
                                                  .dateMonthYear() ??
                                              "",
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey25
                                            : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 0.11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/ic_time.svg",
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                          themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Time'.tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      controller.bookingModel.value.startTime ==
                                              null
                                          ? ""
                                          : controller
                                              .bookingModel.value.startTime!
                                              .time(),
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey25
                                            : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 0.11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icon/ic_distance.svg",
                                      width: 20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                          themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Distance'.tr,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    FutureBuilder<String>(
                                      future: controller.getDistanceInKm(),
                                      initialData: '',
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }
                                        return Text(
                                          snapshot.data ?? '',
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.inter(
                                            color: themeChange.isDarkTheme()
                                                ? AppThemData.grey25
                                                : AppThemData.grey950,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 0.11,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TitleView(
                              titleText: 'Price Details'.tr,
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          Container(
                            width: Responsive.width(100, context),
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(top: 12),
                            decoration: ShapeDecoration(
                              color: themeChange.isDarkTheme()
                                  ? AppThemData.grey900
                                  : AppThemData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Obx(
                              () => Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PriceRowView(
                                    price: controller
                                        .bookingModel.value.fareAmount
                                        .toString(),
                                    title: "Amount".tr,
                                    priceColor: themeChange.isDarkTheme()
                                        ? AppThemData.grey25
                                        : AppThemData.grey950,
                                    titleColor: themeChange.isDarkTheme()
                                        ? AppThemData.grey25
                                        : AppThemData.grey950,
                                  ),
                                  const SizedBox(height: 16),
                                  PriceRowView(
                                      price: "0",
                                      title: "Discount".tr,
                                      priceColor: themeChange.isDarkTheme()
                                          ? AppThemData.grey25
                                          : AppThemData.grey950,
                                      titleColor: themeChange.isDarkTheme()
                                          ? AppThemData.grey25
                                          : AppThemData.grey950),
                                  const SizedBox(height: 16),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 0,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          PriceRowView(
                                              price: "0",
                                              title: "0",
                                              priceColor:
                                                  themeChange.isDarkTheme()
                                                      ? AppThemData.grey25
                                                      : AppThemData.grey950,
                                              titleColor:
                                                  themeChange.isDarkTheme()
                                                      ? AppThemData.grey25
                                                      : AppThemData.grey950),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(
                                      color: themeChange.isDarkTheme()
                                          ? AppThemData.grey800
                                          : AppThemData.grey100),
                                  const SizedBox(height: 12),
                                  PriceRowView(
                                    price: controller
                                        .bookingModel.value.fareAmount
                                        .toString(),
                                    title: "Total Amount".tr,
                                    priceColor: AppThemData.primary400,
                                    titleColor: themeChange.isDarkTheme()
                                        ? AppThemData.grey25
                                        : AppThemData.grey950,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
