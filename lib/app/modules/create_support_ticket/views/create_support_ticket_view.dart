import 'package:dotted_border/dotted_border.dart';
import 'package:customer/app/modules/create_support_ticket/controllers/create_support_ticket_controller.dart';
import 'package:customer/constant_widgets/app_bar_with_border.dart';
import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateSupportTicketView extends GetView<CreateSupportTicketController> {
  const CreateSupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CreateSupportTicketController>(
        init: CreateSupportTicketController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.isDarkTheme()
                ? AppThemData.black
                : AppThemData.white,
            appBar: AppBarWithBorder(
              title: "Create Ticket".tr,
              bgColor: themeChange.isDarkTheme()
                  ? AppThemData.black
                  : AppThemData.white,
            ),
            body: Form(
              key: controller.formKey.value,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title".tr,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: themeChange.isDarkTheme()
                                ? AppThemData.grey25
                                : AppThemData.grey950,
                            fontWeight: FontWeight.w500),
                      ),
                      TextFormField(
                        controller: controller.titleController.value,
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'This field required'.tr,
                        decoration: InputDecoration(hintText: "Enter Title".tr),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Subject".tr,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: themeChange.isDarkTheme()
                                ? AppThemData.grey25
                                : AppThemData.grey950,
                            fontWeight: FontWeight.w500),
                      ),
                      TextFormField(
                        controller: controller.subjectController.value,
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'This field required'.tr,
                        decoration:
                            InputDecoration(hintText: "Enter Subject".tr),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Description".tr,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: themeChange.isDarkTheme()
                                ? AppThemData.grey25
                                : AppThemData.grey950,
                            fontWeight: FontWeight.w500),
                      ),
                      TextFormField(
                        controller: controller.descriptionController.value,
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : 'This field required'.tr,
                        decoration:
                            InputDecoration(hintText: "Enter Description".tr),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          controller.pickMultipleImages();
                        },
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          dashPattern: const [6, 6, 6, 6],
                          child: SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: Center(child: Text("Choose Images".tr)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RoundShapeButton(
                          title: "Submit".tr,
                          buttonColor: AppThemData.primary500,
                          size: const Size(100, 50),
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            if (controller.formKey.value.currentState!
                                .validate()) {
                              controller.createSupportTicket();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
