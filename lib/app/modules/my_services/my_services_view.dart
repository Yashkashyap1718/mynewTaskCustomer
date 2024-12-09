import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyServicesView extends StatelessWidget {
  const MyServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        appBar: AppBarWithBorder(
          title: "Services".tr,
          bgColor:
              themeChange.isDarkTheme() ? AppThemData.black : AppThemData.white,
        ),
        body: Column(
          children: [
            _buildServiceItem(
                context,
                "You have multiple promos",
                "We'll automatically apply the one that saves the most",
                "assets/icon/tag_item.png"),
            _buildServiceItem(
                context,
                "Privacy check-up",
                "Take an interactive tour of your privacy settings",
                "assets/icon/checklist.png"),
          ],
        ));
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
        Column(
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
        Image.asset(serviceImage, width: 50, height: 50),
      ],
    ),
  );
}
