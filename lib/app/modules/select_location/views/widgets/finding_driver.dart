import 'dart:async';
import 'dart:convert';
import 'package:customer/api_services.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/modules/home/views/home_view.dart';
import 'package:customer/app/modules/reason_for_cancel/views/reason_for_cancel_view.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/chat_page_overview.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/pick_drop_point_view.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/models/ride_booking.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/theme/responsive.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FindingDriverBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  BookingModel bookingModel;

  FindingDriverBottomSheet(
      {super.key, required this.scrollController, required this.bookingModel});

  @override
  _FindingDriverBottomSheetState createState() =>
      _FindingDriverBottomSheetState();
}

class _FindingDriverBottomSheetState extends State<FindingDriverBottomSheet> {
  final isLoading = true.obs;
  final rideData = <String, dynamic>{}.obs;
  final userModel = DriverUserModel().obs;
  bool isPolling = true; // To stop polling when widget is disposed

  @override
  void initState() {
    super.initState();
    // _fetchRideRequest();
  }

  @override
  void dispose() {
    isPolling = false;
    // timer.cancel();
    super.dispose();
  }

  Future<void> _fetchRideRequest() async {
    while (isPolling && rideData['status'] != 'accepted') {
      try {
        final response = await http.get(
          Uri.parse(baseURL + realtimeRequest),
          headers: {"Content-Type": "application/json", "token": token},
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == true) {
            rideData.value = responseData['data'];

            if (rideData['driver_id'] != null &&
                rideData['driver_id'].isNotEmpty) {
              final driverProfile = await FireStoreUtils.getDriverUserProfile(
                  rideData['driver_id']);
              userModel.value = driverProfile ?? DriverUserModel();
              print("DriverMODDDDDD: ${jsonEncode(userModel.value)}");
            }

            isLoading.value = false;
          } else {
            rideData.value = {}; // Handle empty data
          }
        } else {
          print('Failed to fetch ride request data: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching ride request: $error');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isFirst = true;
    return Container(
      height: Responsive.height(100, context),
      decoration: BoxDecoration(
        color:
            themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          children: [
            // _buildHandleBar(themeChange),
            StreamBuilder<RideBooking?>(
              stream: checkRequest(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  if (isFirst) {
                    isFirst = false;
                    return Container();
                  } else {
                    ShowToastDialog.showToast("Ride Completed");
                    Navigator.pop(context);
                    // Get.offAll(const HomeView());
                    return Container();
                  }
                }

                if (snapshot.data!.status == "requested") {
                  ShowToastDialog.showToast("Searching for Driver...");
                  // Get.offAll(const HomeView());
                  // Get.back();
                  // Get.to(const HomeView());
                } else if (snapshot.data!.status == "completed") {
                  ShowToastDialog.showToast("Ride Completed");
                  Get.offAll(const HomeView());
                  // Get.back();
                  // Get.to(const HomeView());
                } else if (snapshot.data!.status == 'inProgress') {
                  FireStoreUtils.getDriverUserProfile(
                          snapshot.data!.driver.id ?? '')
                      .then((value) {
                    userModel.value = value ?? DriverUserModel();
                  });
                } else if (snapshot.data!.status == 'rejected') {
                  ShowToastDialog.showToast("Your Ride Rejected...");
                  Get.back();
                }
                widget.bookingModel.driverId = snapshot.data!.driver.id;
                return (snapshot.data!.driver.id.isNotEmpty &&
                        (snapshot.data!.status == "accepted" ||
                            snapshot.data!.status == "in_progress"))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Text(
                              (snapshot.data!.status == "in_progress")
                                  ? "Ride Started"
                                  : 'Driver is Arriving....'.tr,
                              style: GoogleFonts.inter(
                                color: themeChange.isDarkTheme()
                                    ? AppThemData.grey25
                                    : AppThemData.grey950,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (snapshot.data!.status != "in_progress")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: SizedBox(
                                width: Responsive.width(100, context),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    Text(
                                      'Your OTP for this Ride is '.tr,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey25
                                            : AppThemData.grey950,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data!.otp ?? '',
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(
                                        color: themeChange.isDarkTheme()
                                            ? AppThemData.grey25
                                            : AppThemData.grey950,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          Container(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 10),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: themeChange.isDarkTheme()
                                        ? AppThemData.grey950
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          Constant.profileConstant),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        snapshot.data!.driver.name,
                                        style: GoogleFonts.inter(
                                          color: themeChange.isDarkTheme()
                                              ? AppThemData.grey25
                                              : AppThemData.grey950,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if ((userModel.value.reviewsSum ?? '')
                                              .isNotEmpty) ...{
                                            const Icon(Icons.star_rate_rounded,
                                                color: AppThemData.warning500)
                                          },
                                          Text(
                                            (userModel.value.reviewsSum ??
                                                    'No reviews yet')
                                                .toString(),
                                            style: GoogleFonts.inter(
                                              color: themeChange.isDarkTheme()
                                                  ? AppThemData.white
                                                  : AppThemData.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatPageOverview(
                                            studentId:
                                                snapshot.data!.passenger.id,
                                            teacherId: snapshot.data!.driver.id,
                                            studentName:
                                                snapshot.data!.passenger.name ??
                                                    '',
                                            teacherName:
                                                snapshot.data!.driver.name,
                                            showAppBar: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                        "assets/icon/ic_message.svg")),
                                const SizedBox(width: 12),
                                InkWell(
                                    onTap: () {
                                      Constant().launchCall(
                                          "${userModel.value.countryCode}${userModel.value.phoneNumber}");
                                    },
                                    child: SvgPicture.asset(
                                        "assets/icon/ic_phone.svg"))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: PickDropPointView(
                                pickUpAddress:
                                    snapshot.data!.pickupAddress ?? '',
                                dropAddress:
                                    snapshot.data!.dropoffAddress ?? ''),
                          ),
                          if (snapshot.data!.status != "in_progress")
                            RoundShapeButton(
                                size: Size(Responsive.width(100, context), 45),
                                title: "Cancel",
                                buttonColor: AppThemData.danger500,
                                buttonTextColor: AppThemData.white,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReasonForCancelView(
                                                rideData: snapshot.data!)),
                                  );

                                  // Get.to(const ReasonForCancelView(rideData: snapshot.data,),
                                  //     arguments: {"RideBooking": snapshot.data});
                                }),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirming your trip',
                            style: GoogleFonts.inter(
                              color: themeChange.isDarkTheme()
                                  ? AppThemData.white
                                  : AppThemData.grey950,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: PickDropPointView(
                                pickUpAddress:
                                    snapshot.data!.pickupAddress ?? '',
                                dropAddress:
                                    snapshot.data!.dropoffAddress ?? ''),
                          ),
                          RoundShapeButton(
                              size: Size(Responsive.width(100, context), 45),
                              title: "Cancel",
                              buttonColor: AppThemData.danger500,
                              buttonTextColor: AppThemData.white,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReasonForCancelView(
                                          rideData: snapshot.data!)),
                                );

                                Get.to(
                                    ReasonForCancelView(
                                        rideData: snapshot.data!),
                                    arguments: {"RideBooking": snapshot.data});
                              }),
                        ],
                      );

                // if (snapshot.connectionSs/ Hide completely if no bookings are available
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(DarkThemeProvider themeChange) {
    return Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: ShapeDecoration(
        color: themeChange.isDarkTheme()
            ? AppThemData.grey700
            : AppThemData.grey200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildRideDetails(
      BuildContext context, DarkThemeProvider themeChange) {
    print("TYPPEEEE:: ${rideData['status']}");
    if (rideData['status'] == "requested") {
      return Column(
        children: [
          const Center(child: Text('Searching for driver...')),
          _buildConfirmationProgress(themeChange),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: PickDropPointView(
              pickUpAddress: rideData['pickup_address'] ?? '',
              dropAddress: rideData['dropoff_address'] ?? '',
            ),
          ),
          RoundShapeButton(
            size: Size(Responsive.width(100, context), 45),
            title: "Cancel",
            buttonColor: AppThemData.danger500,
            buttonTextColor: AppThemData.white,
            onTap: () {
              Get.back();
            },
          ),
        ],
      );
    } else if (rideData['status'] == 'accepted') {
      return _buildDriverArrivingSection(themeChange);
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget _buildConfirmationProgress(DarkThemeProvider themeChange) {
    return Column(
      children: [
        Text(
          'Confirming your trip'.tr,
          style: GoogleFonts.inter(
            color: themeChange.isDarkTheme()
                ? AppThemData.white
                : AppThemData.grey950,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const LinearProgressIndicator(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDriverArrivingSection(DarkThemeProvider themeChange) {
    if (userModel.value.fullName != null) {
      return _buildDriverInfo(themeChange);
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Driver is Arriving....',
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey25
                    : AppThemData.grey950,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Your OTP for this ride is ${rideData['otp'] ?? ''}',
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey25
                    : AppThemData.grey950,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDriverInfo(DarkThemeProvider themeChange) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: themeChange.isDarkTheme()
                ? AppThemData.grey800
                : AppThemData.grey100,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildDriverImage(),
          Expanded(
            child: _buildDriverDetails(themeChange),
          ),
          _buildContactIcons(),
        ],
      ),
    );
  }

  Widget _buildDriverImage() {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(right: 10),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(Constant.profileConstant),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildDriverDetails(DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              userModel.value.fullName ?? 'Driver Name',
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.grey25
                    : AppThemData.grey950,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
        Row(
          children: [
            if ((userModel.value.reviewsSum ?? '').isNotEmpty)
              const Icon(Icons.star_rate_rounded,
                  color: AppThemData.warning500),
            Text(
              userModel.value.reviewsSum ?? 'No reviews yet',
              style: GoogleFonts.inter(
                color: themeChange.isDarkTheme()
                    ? AppThemData.white
                    : AppThemData.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactIcons() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Get.toNamed(Routes.TRACK_RIDE_SCREEN, arguments: {
              "bookingModel": widget.bookingModel,
            });
            // Get.toNamed(Routes.CHAT_SCREEN,arguments: {"receiverId":userModel.value.id,"rideID":rideData.value["_id"],"driverId":rideData.value["driver_id"]});
          },
          child: SvgPicture.asset("assets/icon/ic_message.svg"),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            Constant().launchCall(
                "${userModel.value.countryCode}${userModel.value.phoneNumber}");
          },
          child: SvgPicture.asset("assets/icon/ic_phone.svg"),
        ),
      ],
    );
  }
}
