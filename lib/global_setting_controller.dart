

// class GlobalSettingController extends GetxController {
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     notificationInit();
//     getCurrentCurrency();
//     getVehicleTypeList();
//     getLanguage();
//     // getTax();
//     super.onInit();
//   }
//
//   getCurrentCurrency() async {
//     await FireStoreUtils().getCurrency().then((value) {
//       if (value != null) {
//         Constant.currencyModel = value;
//       } else {
//         Constant.currencyModel = CurrencyModel(
//             id: "",
//             code: "IND",
//             decimalDigits: 2,
//             active: true,
//             name: "Indian Rupee",
//             symbol: "₹",
//             symbolAtRight: false);
//       }
//     });
//
//     // await FireStoreUtils().getSettings();
//     // await FireStoreUtils().getPayment();
//     AppThemData.primary400 = HexColor.fromHex(Constant.appColor.toString());
//   }
//
//   getVehicleTypeList() async {
//     // await FireStoreUtils.getVehicleType().then((value) {
//     //   if (value != null) {
//     //     Constant.vehicleTypeList = value;
//     //   }
//     // });
//   }
//
//   NotificationService notificationService = NotificationService();
//
//   notificationInit() {
//     notificationService.initInfo().then((value) async {
//       String token = await NotificationService.getToken();
//       log(":::::::TOKEN:::::: $token");
//       if (FirebaseAuth.instance.currentUser != null) {
//         await FireStoreUtils.getUserProfile().then((value) {
//           if (value != null) {
//             UserModel userModel = value;
//             userModel.fcmToken = token;
//             // FireStoreUtils.updateUser(userModel);
//           }
//         });
//       }
//     });
//   }
//
//   getLanguage() async {
//     if (Preferences.getString(Preferences.languageCodeKey)
//         .toString()
//         .isNotEmpty) {
//       LanguageModel languageModel = await Constant.getLanguage();
//       LocalizationService().changeLocale(languageModel.code.toString());
//     } else {
//       LanguageModel languageModel = LanguageModel(
//         id: "CcrGiUvJbPTXaU31s5l8",
//         name: "English",
//         code: "en",
//       );
//       LocalizationService().changeLocale(languageModel.code.toString());
//     }
//   }
//
//   // getTax() async {
//   //   await FireStoreUtils().getTaxList().then((value) {
//   //     if (value != null) {
//   //       Constant.taxList = value;
//   //     }
//   //   });
//   // }
// }
