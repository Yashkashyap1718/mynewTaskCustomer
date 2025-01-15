import 'package:customer/app/modules/my_services/controllers/service_list_controller.dart';
import 'package:customer/app/modules/my_services_details/views/service_details_view.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServiceListView extends GetView<ServiceListController> {
  const ServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder(
        init: ServiceListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBarWithBorder(
              title: "Services".tr,
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
                return ListView(
                  children: controller.serviceList
                      .map((element) => InkWell(
                            onTap: () {
                              Get.to(ServiceDetailsView(
                                  serviceListModal: element));
                            },
                            child: _buildServiceItem(
                              context,
                              element.title,
                              element.description,
                              element.image,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          );
        });
  }
}

Widget _buildServiceItem(BuildContext context, String serviceName,
    String serviceDescription, String serviceImage) {
  final themeChange = Provider.of<DarkThemeProvider>(context);
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppThemData.grey08),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: GoogleFonts.inter(
                  color: themeChange.isDarkTheme()
                      ? AppThemData.white
                      : AppThemData.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                serviceDescription,
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
        ),
        Image.network(
          "$imageBaseUrl$serviceImage",
          width: 50,
          height: 50,
        ),
      ],
    ),
  );
}
