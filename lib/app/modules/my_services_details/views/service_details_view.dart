import 'package:customer/app/models/service_list_modal.dart';
import 'package:customer/app/modules/my_services/controllers/service_list_controller.dart';
import 'package:customer/app/modules/my_services_details/controllers/service_details_controller.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServiceDetailsView extends GetView<ServiceDetailsController> {
  final ServiceListModal serviceListModal;
  const ServiceDetailsView({super.key, required this.serviceListModal});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder(
        init: ServiceListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBarWithBorder(
              title: "Services Details".tr,
              bgColor: themeChange.isDarkTheme()
                  ? AppThemData.black
                  : AppThemData.white,
            ),
            body: Obx(
              () {
                if (controller.serviceList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return _buildServiceItem(
                  context,
                  serviceListModal.title,
                  serviceListModal.description,
                  serviceListModal.subtitle,
                );
              },
            ),
          );
        });
  }
}

Widget _buildServiceItem(BuildContext context, String serviceName,
    String serviceDescription, String subTitle) {
  final themeChange = Provider.of<DarkThemeProvider>(context);
  return Container(
    padding: EdgeInsets.all(20),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 80,
          padding: EdgeInsets.only(left: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              serviceName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          subTitle,
          style: GoogleFonts.inter(
            color: themeChange.isDarkTheme()
                ? AppThemData.white
                : AppThemData.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20),
        Text(
          subTitle,
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
  );
}
