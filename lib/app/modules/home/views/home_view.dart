import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/api_services.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/my_ride_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/modules/language/views/language_view.dart';
import 'package:customer/app/modules/my_ride_details/controllers/my_ride_details_controller.dart';
import 'package:customer/app/modules/my_ride_details/views/my_ride_details_view.dart';
import 'package:customer/app/modules/notification/views/notification_view.dart';
import 'package:customer/app/modules/select_location/views/widgets/select_location_bottom_sheet.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant_widgets/no_rides_view.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/extension/date_time_extension.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/app/modules/home/controllers/home_controller.dart';
import 'package:customer/app/modules/home/views/widgets/drawer_view.dart';
import 'package:customer/app/modules/my_ride/views/my_ride_view.dart';
import 'package:customer/app/modules/my_wallet/views/my_wallet_view.dart';
import 'package:customer/app/modules/support_screen/views/support_screen_view.dart';
import 'package:customer/app/modules/html_view_screen/views/html_view_screen_view.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    Get.put(HomeController());
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: _buildAppBar(themeChange),
          body: _buildBody(controller, themeChange, context),
          drawer: DrawerView(user: controller.userData),
        );
      },
    );
  }

  AppBar _buildAppBar(DarkThemeProvider themeChange) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: _buildAppBarTitle(themeChange),
      centerTitle: true,
      actions: [_buildNotificationButton()],
    );
  }

  Row _buildAppBarTitle(DarkThemeProvider themeChange) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/icon/logo_only.jpeg", height: 30, width: 30),
        const SizedBox(width: 10),
        Text(
          'Travel Teacher'.tr,
          style: GoogleFonts.inter(
            color: themeChange.isDarkTheme()
                ? AppThemData.white
                : AppThemData.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  IconButton _buildNotificationButton() {
    return IconButton(
      onPressed: () {
        Get.to(const NotificationView());
      },
      icon: const Icon(Icons.notifications_none_rounded),
    );
  }

  Widget _buildBody(HomeController controller, DarkThemeProvider themeChange,
      BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Constant.loader();
      }

      switch (controller.drawerIndex.value) {
        case 1:
          return const MyRideView();
        case 2:
          return const MyWalletView();
        case 3:
          return const SupportScreenView();
        case 4:
          return HtmlViewScreenView(
              title: "Privacy & Policy".tr, htmlData: Constant.privacyPolicy);
        case 5:
          return HtmlViewScreenView(
              title: "Terms & Condition".tr,
              htmlData: Constant.termsAndConditions);
        case 6:
          return const LanguageView();
        default:
          return _buildMainContent(controller, themeChange, context);
      }
    });
  }

  Widget _buildMainContent(HomeController controller,
      DarkThemeProvider themeChange, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchContainer(controller, themeChange, context),
            const SizedBox(height: 20),
            BannerView(),
            _buildSectionTitle('Your Rides'.tr, themeChange),
            const SizedBox(height: 20),
            _buildRideList(controller, themeChange),
            _buildOfferBanner(controller, themeChange, context),
            const SizedBox(height: 20),
            _buildLastRideSection(controller, themeChange),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContainer(HomeController controller,
      DarkThemeProvider themeChange, BuildContext context) {
    return InkWell(
      onTap: () {
        // Get.toNamed(Routes.SELECT_LOCATION, arguments: controller.bookingModel);
      },
      child: Container(
        width: Responsive.width(100, context),
        height: 56,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: themeChange.isDarkTheme()
              ? AppThemData.grey900
              : AppThemData.grey50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed(Routes.SELECT_LOCATION);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded,
                  color: themeChange.isDarkTheme()
                      ? AppThemData.grey400
                      : AppThemData.grey500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Where to?'.tr,
                  style: GoogleFonts.inter(
                    color: themeChange.isDarkTheme()
                        ? AppThemData.grey400
                        : AppThemData.grey500,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, DarkThemeProvider themeChange) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: themeChange.isDarkTheme()
            ? AppThemData.grey25
            : AppThemData.grey950,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRideList(
      HomeController controller, DarkThemeProvider themeChange) {
    bool once = false;
    return StreamBuilder<RideBooking?>(
      stream: checkRequest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Constant.loader();
        }
        if (!snapshot.hasData) {
          // if (lastRide != null) {
          //   controller.bookingModel.value = lastRide;
          // } else {
          return NoRidesView(
              themeChange: themeChange, height: Responsive.height(40, context));
          // }
        } else {
          controller.bookingModel.value = snapshot.data!;
        }

        try {
          controller.sourceLocation = LatLng(
              controller.bookingModel.value?.pickupLocation.coordinates[0] ?? 0,
              controller.bookingModel.value?.pickupLocation.coordinates[1] ??
                  0);
          controller.destination = LatLng(
              controller.bookingModel.value?.dropoffLocation.coordinates[0] ??
                  0,
              controller.bookingModel.value?.dropoffLocation.coordinates[1] ??
                  0);
          if (!once) {
            controller.getData();
            once = true;
          }
          controller.update();
        } catch (e) {}

        RideBooking bookingModelList = snapshot.data!;

        return InkWell(
          onTap: () {
            Get.toNamed(Routes.SELECT_LOCATION, arguments: bookingModelList);

            // MyRideDetailsController detailsController = Get.put(MyRideDetailsController());
            // detailsController.bookingId.value = bookingModelList.id ?? '';
            // detailsController.bookingModel.value = bookingModelList;
            // Get.to(const MyRideDetailsView());
          },
          child: Container(
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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      {
                            "pending": "Pending",
                            "accepted": "Accepted",
                            "requested": "Requested",
                            "rejected": "Rejected",
                            "cancelled": "Cancelled",
                            "onGoing": "On Going",
                            "waiting": "Waiting",
                            "started": "Started",
                            "arrived": "Arrived",
                            "in_progress": "In Progress",
                            "completed": "Completed",
                          }[bookingModelList.status] ??
                          "Unknown",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: BookingStatus.getBookingStatusTitleColor(
                            bookingModelList.status),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: PickDropPointView(
                      pickUpAddress: snapshot.data!.pickupAddress ?? '',
                      dropAddress: snapshot.data!.dropoffAddress ?? ''),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: Constant.profileConstant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookingModelList.driver.name == ''
                                  ? 'Waiting for Driver'
                                  : bookingModelList.driver.name ??
                                      'Waiting for Driver',
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme()
                                    ? AppThemData.grey25
                                    : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (bookingModelList.status == "accepted")
                              Row(
                                children: [
                                  Text(
                                    'OTP : '.tr,
                                    style: GoogleFonts.inter(
                                      color: themeChange.isDarkTheme()
                                          ? AppThemData.grey25
                                          : AppThemData.grey950,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    bookingModelList.otp,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.inter(
                                      color: AppThemData.primary400,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
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
                            bookingModelList.fareAmount.toString(),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icon/ic_multi_person.svg",
                                color: themeChange.isDarkTheme()
                                    ? AppThemData.grey25
                                    : AppThemData.grey950,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bookingModelList.vehicleType == null
                                    ? ""
                                    : bookingModelList.vehicleType!.persons,
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme()
                                      ? AppThemData.grey25
                                      : AppThemData.grey950,
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
              ],
            ),
          ),
        );

        // return ListView.builder(
        //   shrinkWrap: true,
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemCount: 1,
        //   itemBuilder: (context, index) {
        //     return _buildRideItem(bookingModelList, themeChange, context);
        //   },
        // );
      },
    );
  }

  Widget _buildRideItem(RideBooking bookingModelList,
      DarkThemeProvider themeChange, BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.SELECT_LOCATION, arguments: bookingModelList);
      },
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRideDetails(bookingModelList, themeChange),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetails(
      RideBooking bookingModelList, DarkThemeProvider themeChange) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateTime.fromMillisecondsSinceEpoch(bookingModelList.createdAt)
              .time(),
          style: GoogleFonts.inter(
            color: themeChange.isDarkTheme()
                ? AppThemData.grey400
                : AppThemData.grey500,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          BookingStatus.getBookingStatusTitle(bookingModelList.status),
          style: GoogleFonts.inter(
            color: BookingStatus.getBookingStatusTitleColor(
                bookingModelList.status),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferBanner(HomeController controller,
      DarkThemeProvider themeChange, BuildContext context) {
    return Container(
      width: Responsive.width(100, context),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: ShapeDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/offer_banner_background.png"),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expanded Seating Offer',
            style: GoogleFonts.inter(
              color: AppThemData.primary400,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 18),
            child: Text(
              'Our 4-seater sedans now accommodate an extra passenger at no additional cost!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          RoundShapeButton(
            size: const Size(200, 34),
            title: "Book Now".tr,
            buttonColor: themeChange.isDarkTheme()
                ? AppThemData.white
                : AppThemData.black,
            buttonTextColor: AppThemData.black,
            onTap: () {
              Get.toNamed(Routes.SELECT_LOCATION);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLastRideSection(
      HomeController controller, DarkThemeProvider themeChange) {
    return Column(
      children: [
        FutureBuilder<List<MyRideModel>>(
          future: getRidesList(myRidesEndPoint),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            List<MyRideModel> myRideList = snapshot.data!;

            return ListView.builder(
              itemCount: 1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                RxBool isOpen = false.obs;
                MyRideModel bookingModel = myRideList[index];
                return InkWell(
                  onTap: () {
                    MyRideDetailsController detailsController =
                        Get.put(MyRideDetailsController());
                    detailsController.bookingId.value = bookingModel.id ?? '';
                    detailsController.bookingModel.value = bookingModel;
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            isOpen.value = !isOpen.value;
                            Get.toNamed(Routes.SELECT_LOCATION);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                height: 15,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      color: themeChange.isDarkTheme()
                                          ? AppThemData.grey800
                                          : AppThemData.grey100,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd-MM-yyyy , HH:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        bookingModel.createdAt!)),
                                style: GoogleFonts.inter(
                                  color: themeChange.isDarkTheme()
                                      ? AppThemData.grey400
                                      : AppThemData.grey500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_right_sharp,
                                color: themeChange.isDarkTheme()
                                    ? AppThemData.grey400
                                    : AppThemData.grey500,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Amount: ${bookingModel.fareAmount}',
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? Colors.green
                                            : Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'Dropoff Location: ${bookingModel.dropoffAddress}',
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey400
                                            : AppThemData.grey500,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class BannerView extends StatelessWidget {
  BannerView({super.key});

  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<BannerModel>>(
          future: getBanners(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox();
            }

            List<BannerModel> bannerList = snapshot.data!;
            return Column(
              children: [
                SizedBox(
                  height: Responsive.height(22, context),
                  child: PageView.builder(
                    itemCount: bannerList.length,
                    controller: controller.pageController,
                    onPageChanged: (value) {
                      controller.curPage.value = value;
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        width: Responsive.width(100, context),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                imageBaseUrl + (bannerList[index].image ?? "")),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Container(
                          width: Responsive.width(100, context),
                          padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                          decoration: ShapeDecoration(
                            color: AppThemData.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bannerList[index].bannerName ?? '',
                                style: GoogleFonts.inter(
                                  color: AppThemData.grey50,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                width: Responsive.width(100, context),
                                margin:
                                    const EdgeInsets.only(top: 6, bottom: 6),
                                child: Text(
                                  bannerList[index].bannerDescription ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: AppThemData.grey50,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    bannerList[index].isOfferBanner ?? false,
                                child: Text(
                                  bannerList[index].offerText ?? '',
                                  style: GoogleFonts.inter(
                                    color: AppThemData.primary400,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
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
                Center(
                  child: SizedBox(
                    height: 8,
                    child: ListView.builder(
                      itemCount: bannerList.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Obx(
                          () => Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == controller.curPage.value
                                  ? AppThemData.primary400
                                  : AppThemData.grey200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
