import 'package:customer/constant_widgets/round_shape_button.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/validate_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../theme/responsive.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    final TextEditingController phoneController = TextEditingController();

    return GetBuilder<LoginController>(
        init: LoginController(),
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              bool isFocus = FocusScope.of(context).hasFocus;
              if (isFocus) {
                FocusScope.of(context).unfocus();
              }
            },
            child: Scaffold(
              backgroundColor: themeChange.isDarkTheme()
                  ? AppThemData.black
                  : AppThemData.white,
              appBar: AppBar(
                  backgroundColor: themeChange.isDarkTheme()
                      ? AppThemData.black
                      : AppThemData.white,
                  automaticallyImplyLeading: false),
              body: Container(
                width: Responsive.width(100, context),
                height: Responsive.height(100, context),
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Center(
                            child: Image.asset(
                          themeChange.isDarkTheme()
                              ? "assets/images/taxi.png"
                              : "assets/images/taxi.png",
                          scale: 6,
                        )),
                      ),
                      Text(
                        "Login".tr,
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            color: themeChange.isDarkTheme()
                                ? AppThemData.white
                                : AppThemData.black,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "Please login to continue".tr,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: themeChange.isDarkTheme()
                                ? AppThemData.white
                                : AppThemData.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Container(
                        // height: 110,
                        width: Responsive.width(100, context),
                        margin: const EdgeInsets.only(top: 36, bottom: 48),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppThemData.grey100)),
                        child: Form(
                          key: controller.formKey.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container(
                              //   height: 45,
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: CountryCodeSelectorView(
                              //     isCountryNameShow: true,
                              //     countryCodeController:
                              //         controller.countryCodeController,
                              //     isEnable: true,
                              //     onChanged: (value) {
                              //       controller.countryCodeController.text =
                              //           value.dialCode.toString();
                              //     },
                              //   ),
                              // ),
                              // const Divider(color: AppThemData.grey100),
                              SizedBox(
                                height: 45,
                                child: TextFormField(
                                  cursorColor: themeChange.isDarkTheme()
                                      ? AppThemData.white
                                      : AppThemData.black,
                                  keyboardType: TextInputType.number,
                                  controller: controller.phoneNumberController,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                  validator: (value) => validateMobile(
                                      value,
                                      controller
                                          .countryCodeController.value.text),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(
                                        left: 15, bottom: 0, top: 0, right: 15),
                                    hintText: "Enter your Phone Number".tr,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: RoundShapeButton(
                          size: const Size(200, 45),
                          title: "Send OTP".tr,
                          buttonColor: AppThemData.primary400,
                          buttonTextColor: AppThemData.black,
                          onTap: () {
                            print(
                                'Button tapped!'); // Check if the button is tapped

                            if (controller.formKey.value.currentState!
                                .validate()) {
                              print(
                                  'Form validation passed!'); // Check if form validation passes

                              // Call sendOTP function
                              controller.sendOTP(context);

                              print(
                                  'OTP function called!'); // Check if the sendOTP function is called
                            } else {
                              print(
                                  'Form validation failed!'); // Handle form validation failure
                            }
                          },
// if(controller.formKey.value.currentState!.validate()){

//   try {
//                                 final http.Response response = await http.post(
//                                   Uri.parse(baseURL + sendOtpEndpoint),
//                                   headers: <String, String>{
//                                     'Content-Type': 'application/json',
//                                   },
//                                   body: {
//                                     "country_code": "91",
//                                     "mobile_number": phoneController.text
//                                   },
//                                 );
//                                 print(phoneController.text);
//                                 log(response.body);
//                                 // if (response.statusCode == 200) {
//                                 final Map<String, dynamic> responseData =
//                                     jsonDecode(response.body);
//                                 final String msg = responseData['msg'];
//                                 final List<String> parts = msg.split(',');
//                                 final String otp = parts.first.trim();

//                                 print(otp);

//                                 Get.to(
//                                   VerifyOtpView(
//                                     phoneNumder: phoneController.text,
//                                     oTP: otp,
//                                   ),
//                                 );
//                                 // } else {
//                                 //   throw Exception('Failed to send request');
//                                 // }
//                               } catch (e) {
//                                 log('Error: $e');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         'Error occurred while sending request.'),
//                                   ),
//                                 );
//                               }
// }

                          // } else {
                          //   ShowToastDialog.showToast(
                          //       'Please enter a valid number'.tr);
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 20, bottom: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Container(
                      //         width: 52,
                      //         margin: const EdgeInsets.only(right: 10),
                      //         child: const Divider(color: AppThemData.grey100),
                      //       ),
                      //       Text(
                      //         "Continue with".tr,
                      //         style: GoogleFonts.inter(
                      //             fontSize: 12,
                      //             color: AppThemData.grey400,
                      //             fontWeight: FontWeight.w400),
                      //       ),
                      //       Container(
                      //         width: 52,
                      //         margin: const EdgeInsets.only(left: 10),
                      //         child: const Divider(color: AppThemData.grey100),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // Visibility(
                      //   visible: Platform.isIOS,
                      //   child: Center(
                      //     child: InkWell(
                      //       onTap: () {
                      //         controller.loginWithApple();
                      //       },
                      //       child: Container(
                      //         height: 45,
                      //         width: 200,
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(200),
                      //             border: Border.all(
                      //               color: themeChange.isDarkTheme()
                      //                   ? AppThemData.white
                      //                   : AppThemData.grey100,
                      //             )),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             SvgPicture.asset(
                      //               "assets/icon/ic_apple.svg",
                      //               height: 24,
                      //               width: 24,
                      //               colorFilter: ColorFilter.mode(
                      //                   themeChange.isDarkTheme()
                      //                       ? AppThemData.white
                      //                       : AppThemData.black,
                      //                   BlendMode.srcIn),
                      //             ),
                      //             const SizedBox(width: 12),
                      //             Text(
                      //               'Apple'.tr,
                      //               textAlign: TextAlign.center,
                      //               style: GoogleFonts.inter(
                      //                 color: themeChange.isDarkTheme()
                      //                     ? AppThemData.white
                      //                     : AppThemData.black,
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // Center(
                      //   child: InkWell(
                      //     onTap: () {
                      //       controller.loginWithGoogle();
                      //     },
                      //     child: Container(
                      //       height: 45,
                      //       width: 200,
                      //       decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(200),
                      //           border: Border.all(
                      //             color: themeChange.isDarkTheme()
                      //                 ? AppThemData.white
                      //                 : AppThemData.grey100,
                      //           )),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           SvgPicture.asset("assets/icon/ic_google.svg",
                      //               height: 24, width: 24),
                      //           const SizedBox(width: 12),
                      //           Text(
                      //             'Google'.tr,
                      //             textAlign: TextAlign.center,
                      //             style: GoogleFonts.inter(
                      //               color: themeChange.isDarkTheme()
                      //                   ? AppThemData.white
                      //                   : AppThemData.black,
                      //               fontSize: 14,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
