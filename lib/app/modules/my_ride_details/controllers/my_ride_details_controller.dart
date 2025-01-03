// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:customer/app/models/map_model.dart';
import 'package:customer/app/models/my_ride_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/payment_model/stripe_failed_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart' as razor_pay_flutter;

class MyRideDetailsController extends GetxController {
  RxString bookingId = ''.obs;
  Rx<MyRideModel> bookingModel = MyRideModel().obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxString selectedPaymentMethod = "".obs;
  final razor_pay_flutter.Razorpay _razorpay = razor_pay_flutter.Razorpay();

  @override
  void onInit() {
    getBookingDetails();
    super.onInit();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  getBookingDetails() async {
    // await FireStoreUtils().getPayment().then((value) {
    //   if (value != null) {
    //     paymentModel.value = value;
    //     if (paymentModel.value.strip!.isActive == true) {
    //       Stripe.publishableKey =
    //           paymentModel.value.strip!.clientPublishableKey.toString();
    //       Stripe.merchantIdentifier = 'Travel Teacher';
    //       Stripe.instance.applySettings();
    //     }
    //     if (paymentModel.value.paypal!.isActive == true) {
    //       // initPayPal();
    //     }
    //     if (paymentModel.value.flutterWave!.isActive == true) {
    //       // setRef();
    //     }
    //   }
    // });
    // bookingModel.value =
    //     (await FireStoreUtils.getRideDetails(bookingId.value)) ??
    //         BookingModel();
    selectedPaymentMethod.value = "cash";
    // await getProfileData();
  }

  // getProfileData() async {
  //   await FireStoreUtils.getUserProfile().then((value) {
  //     if (value != null) {
  //       userModel.value = value;
  //     }
  //   });
  // }

  Future<String> getDistanceInKm() async {
    String km = '';
    LatLng departureLatLong = LatLng(
        bookingModel.value.pickupLocation?.coordinates[0] ?? 0.0,
        bookingModel.value.pickupLocation?.coordinates[1] ?? 0.0);
    LatLng destinationLatLong = LatLng(
        bookingModel.value.dropoffLocation?.coordinates[0] ?? 0.0,
        bookingModel.value.dropoffLocation?.coordinates[1] ?? 0.0);
    MapModel? mapModel = await Constant.getDurationDistance(
        departureLatLong, destinationLatLong);
    if (mapModel != null) {
      print("KM : ${mapModel.toJson()}");
      km = mapModel.rows!.first.elements!.first.distance!.text!;
    }
    return km;
  }

  completeOrder(String transactionId) async {
    ShowToastDialog.showLoader("Please wait".tr);

    bookingModel.value.paymentMode = selectedPaymentMethod.value;
    if (bookingModel.value.paymentMode == Constant.paymentModel!.cash!.name) {
      bookingModel.value.paymentStatus =
          selectedPaymentMethod.value == "cash" ? "no-cash" : "cash";
    }
    //if payment type cash -------->send notification to driver
    // WalletTransactionModel transactionModel = WalletTransactionModel(
    //     id: Constant.getUuid(),
    //     amount: Constant.calculateFinalAmount(bookingModel.value).toString(),
    //     createdDate: Timestamp.now(),
    //     paymentType: selectedPaymentMethod.value,
    //     transactionId: transactionId,
    //     userId: bookingModel.value.driverId,
    //     isCredit: true,
    //     type: Constant.typeDriver,
    //     note: "Ride fee Credited ");

    // await FireStoreUtils.setWalletTransaction(transactionModel)
    //     .then((value) async {
    //   if (value == true) {
    //     await FireStoreUtils.updateOtherUserWallet(
    //         amount:
    //             Constant.calculateFinalAmount(bookingModel.value).toString(),
    //         id: bookingModel.value.driverId!);
    //   }
    // });

    // WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
    //     id: Constant.getUuid(),
    //     amount:
    //         "${Constant.calculateAdminCommission(amount: Constant.calculateFinalAmount(bookingModel.value).toString(), adminCommission: bookingModel.value.adminCommission)}",
    //     createdDate: Timestamp.now(),
    //     paymentType: "Wallet",
    //     transactionId: bookingModel.value.id,
    //     isCredit: false,
    //     type: Constant.typeDriver,
    //     userId: bookingModel.value.driverId,
    //     note: "Admin commission Debited",
    //     adminCommission: bookingModel.value.adminCommission);

    // await FireStoreUtils.setWalletTransaction(adminCommissionWallet)
    //     .then((value) async {
    //   if (value == true) {
    //     await FireStoreUtils.updateOtherUserWallet(
    //         amount:
    //             "-${Constant.calculateAdminCommission(amount: Constant.calculateFinalAmount(bookingModel.value).toString(), adminCommission: bookingModel.value.adminCommission)}",
    //         id: bookingModel.value.driverId!);
    //   }
    // });

    // await FireStoreUtils.setBooking(bookingModel.value).then((value) {
    //   ShowToastDialog.closeLoader();
    //   // Get.offAllNamed(Routes.HOME);
    // });

    //   DriverUserModel? receiverUserModel =
    //       await FireStoreUtils.getDriverUserProfile(
    //           bookingModel.value.id.toString());
    //   Map<String, dynamic> playLoad = <String, dynamic>{
    //     "bookingId": bookingModel.value.id
    //   };
    //   await SendNotification.sendOneNotification(
    //       type: "order",
    //       token: receiverUserModel!.fcmToken.toString(),
    //       title: 'Payment Received'.tr,
    //       body:
    //           'Payment Received for Ride #${bookingModel.value.id.toString().substring(0, 4)}',
    //       bookingId: bookingModel.value.id,
    //       driverId: bookingModel.value.id.toString(),
    //       senderId: FireStoreUtils.getCurrentUid(),
    //       payload: playLoad);

    //   await ShowToastDialog.closeLoader();
    //   Get.back();
    //   // Get.offAllNamed(Routes.HOME);
    // }

    // ::::::::::::::::::::::::::::::::::::::::::::Wallet::::::::::::::::::::::::::::::::::::::::::::::::::::
    walletPaymentMethod() async {
      ShowToastDialog.showLoader("Please wait".tr);

      bookingModel.value.paymentStatus = "cash";
      // ShowToastDialog.showToast("Payment successful");
      // WalletTransactionModel transactionModel = WalletTransactionModel(
      //     id: Constant.getUuid(),
      //     amount: Constant.calculateFinalAmount(bookingModel.value).toString(),
      //     createdDate: Timestamp.now(),
      //     paymentType: selectedPaymentMethod.value,
      //     transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
      //     userId: FireStoreUtils.getCurrentUid(),
      //     isCredit: false,
      //     type: Constant.typeCustomer,
      //     note: "Ride fee Debited");

      // await FireStoreUtils.setWalletTransaction(transactionModel)
      //     .then((value) async {
      //   if (value == true) {
      //     await FireStoreUtils.updateUserWallet(
      //             amount:
      //                 "-${Constant.calculateFinalAmount(bookingModel.value).toString()}")
      //         .then((value) async {
      //       await getProfileData();
      //     });
      //   }
      // });
      ShowToastDialog.closeLoader();

      completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
    }

    // ::::::::::::::::::::::::::::::::::::::::::::Stripe::::::::::::::::::::::::::::::::::::::::::::::::::::
    // Future<void> stripeMakePayment({required String amount}) async {
    //   try {
    //     log(double.parse(amount).toStringAsFixed(0));
    //     try {
    //       Map<String, dynamic>? paymentIntentData =
    //           await createStripeIntent(amount: amount);
    //       if (paymentIntentData!.containsKey("error")) {
    //         Get.back();
    //         ShowToastDialog.showToast(
    //             "Something went wrong, please contact admin.");
    //       } else {
    //         await Stripe.instance.initPaymentSheet(
    //             paymentSheetParameters: SetupPaymentSheetParameters(
    //                 paymentIntentClientSecret: paymentIntentData['client_secret'],
    //                 allowsDelayedPaymentMethods: false,
    //                 googlePay: const PaymentSheetGooglePay(
    //                   merchantCountryCode: 'US',
    //                   testEnv: true,
    //                   currencyCode: "USD",
    //                 ),
    //                 style: ThemeMode.system,
    //                 appearance: PaymentSheetAppearance(
    //                   colors: PaymentSheetAppearanceColors(
    //                     primary: AppThemData.primary400,
    //                   ),
    //                 ),
    //                 merchantDisplayName: 'Travel Teacher'));
    //         displayStripePaymentSheet(amount: amount);
    //       }
    //     } catch (e, s) {
    //       log("$e \n$s");
    //       ShowToastDialog.showToast("exception:$e \n$s");
    //     }
    //   } catch (e) {
    //     log('Existing in stripeMakePayment: $e');
    //   }
    // }

    displayStripePaymentSheet({required String amount}) async {
      try {
        await Stripe.instance.presentPaymentSheet().then((value) {
          ShowToastDialog.showToast("Payment successfully");
          bookingModel.value.paymentStatus = "cash";
          completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
        });
      } on StripeException catch (e) {
        var lo1 = jsonEncode(e);
        var lo2 = jsonDecode(lo1);
        StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
        ShowToastDialog.showToast(lom.error.message);
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
        log('Existing in displayStripePaymentSheet: $e');
      }
    }

    createStripeIntent({required String amount}) async {
      try {
        Map<String, dynamic> body = {
          'amount': ((double.parse(amount) * 100).round()).toString(),
          'currency': "USD",
          'payment_method_types[]': 'card',
          "description": "Strip Payment",
          "shipping[name]": userModel.value.data?.name,
          "shipping[address][line1]": "510 Townsend St",
          "shipping[address][postal_code]": "98140",
          "shipping[address][city]": "San Francisco",
          "shipping[address][state]": "CA",
          "shipping[address][country]": "US",
        };
        log(paymentModel.value.strip!.stripeSecret.toString());
        var stripeSecret = paymentModel.value.strip!.stripeSecret;
        var response = await http.post(
            Uri.parse('https://api.stripe.com/v1/payment_intents'),
            body: body,
            headers: {
              'Authorization': 'Bearer $stripeSecret',
              'Content-Type': 'application/x-www-form-urlencoded'
            });

        return jsonDecode(response.body);
      } catch (e) {
        log(e.toString());
      }
    }

    // ::::::::::::::::::::::::::::::::::::::::::::PayPal::::::::::::::::::::::::::::::::::::::::::::::::::::
    // final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

    // void initPayPal() async {
    //   FlutterPaypalNative.isDebugMode =
    //       paymentModel.value.paypal!.isSandbox == true ? true : false;
    //
    //   await _flutterPaypalNativePlugin.init(
    //     returnUrl: "com.ideativemind.customer://paypalpay",
    //     clientID: paymentModel.value.paypal!.paypalClient.toString(),
    //     payPalEnvironment: paymentModel.value.paypal!.isSandbox == true
    //         ? FPayPalEnvironment.sandbox
    //         : FPayPalEnvironment.live,
    //     currencyCode: FPayPalCurrencyCode.usd,
    //     action: FPayPalUserAction.payNow,
    //   );
    //
    //   _flutterPaypalNativePlugin.setPayPalOrderCallback(
    //     callback: FPayPalOrderCallback(
    //       onCancel: () {
    //         ShowToastDialog.closeLoader();
    //         ShowToastDialog.showToast("Payment canceled");
    //       },
    //       onSuccess: (data) {
    //         _flutterPaypalNativePlugin.removeAllPurchaseItems();
    //         String visitor = data.cart?.shippingAddress?.firstName ?? 'Visitor';
    //         String address =
    //             data.cart?.shippingAddress?.line1 ?? 'Unknown Address';
    //         ShowToastDialog.showToast("Payment Successfully");
    //         bookingModel.value.paymentStatus = true;
    //         ShowToastDialog.closeLoader();
    //         completeOrder(
    //             data.orderId ?? DateTime.now().millisecondsSinceEpoch.toString());
    //       },
    //       onError: (data) {
    //         ShowToastDialog.closeLoader();
    //         ShowToastDialog.showToast("error: ${data.reason}");
    //       },
    //       onShippingChange: (data) {
    //         ShowToastDialog.closeLoader();
    //         ShowToastDialog.showToast(
    //             "shipping change: ${data.shippingChangeAddress?.adminArea1 ?? ""}");
    //       },
    //     ),
    //   );
    // }

    paypalPaymentSheet(String amount) {
      ShowToastDialog.showLoader("Please wait".tr);
      // if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
      //   _flutterPaypalNativePlugin.addPurchaseUnit(
      //     FPayPalPurchaseUnit(
      //       amount: double.parse(amount),
      //       referenceId: FPayPalStrHelper.getRandomString(16),
      //     ),
      //   );
      // }
      //
      // _flutterPaypalNativePlugin.makeOrder(
      //   action: FPayPalUserAction.payNow,
      // );
    }

    // ::::::::::::::::::::::::::::::::::::::::::::RazorPay::::::::::::::::::::::::::::::::::::::::::::::::::::

    // Future<void> razorpayMakePayment({required String amount}) async {
    //   try {
    //     ShowToastDialog.showLoader("Please wait".tr);
    //     var options = {
    //       'key': paymentModel.value.razorpay!.razorpayKey,
    //       "razorPaySecret": paymentModel.value.razorpay!.razorpayKey,
    //       'amount': double.parse(amount) * 100,
    //       "currency": "INR",
    //       'name': userModel.value.fullName,
    //       "isSandBoxEnabled": paymentModel.value.razorpay!.isSandbox,
    //       'external': {
    //         'wallets': ['paytm']
    //       },
    //       'send_sms_hash': true,
    //       'prefill': {
    //         'contact': userModel.value.phoneNumber,
    //         'email': userModel.value.email
    //       },
    //     };

    //     _razorpay.open(options);
    //     _razorpay.on(razor_pay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS,
    //         _handlePaymentSuccess);
    //     _razorpay.on(
    //         razor_pay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    //     _razorpay.on(razor_pay_flutter.Razorpay.EVENT_EXTERNAL_WALLET,
    //         _handleExternalWallet);
    //   } catch (e) {
    //     log('Error in razorpayMakePayment: $e');
    //   }
    // }

    // void _handlePaymentSuccess(PaymentSuccessResponse response) {
    //   // Payment success logic
    //   ShowToastDialog.showToast("Payment Successfully");
    //   bookingModel.value.paymentStatus = "cash";

    //   log('Payment Success: ${response.paymentId}');
    //   _razorpay.clear();
    //   _razorpay = razor_pay_flutter.Razorpay();
    //   completeOrder(
    //       response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
    //   ShowToastDialog.closeLoader();
    // }

    // void _handlePaymentError(PaymentFailureResponse response) {
    //   // Payment failure logic
    //   log('Payment Error: ${response.code} - ${response.message}');
    //   ShowToastDialog.showToast('Payment failed. Please try again.');
    //   ShowToastDialog.closeLoader();
    // }

    // void _handleExternalWallet(ExternalWalletResponse response) {
    //   // External wallet selection logic
    //   log('External Wallet: ${response.walletName}');
    //   ShowToastDialog.closeLoader();
    // }

    // ::::::::::::::::::::::::::::::::::::::::::::FlutterWave::::::::::::::::::::::::::::::::::::::::::::::::::::
    // flutterWaveInitiatePayment(
    //     {required BuildContext context, required String amount}) async {
    //   final flutterWave = Flutterwave(
    //     amount: amount.trim(),
    //     currency: Constant.currencyModel!.code ?? "NGN",
    //     customer: Customer(
    //         name: userModel.value.fullName.toString(),
    //         phoneNumber: userModel.value.phoneNumber.toString(),
    //         email: userModel.value.email.toString()),
    //     context: context,
    //     publicKey: paymentModel.value.flutterWave!.publicKey.toString().trim(),
    //     paymentOptions: "ussd, card, barter, payattitude",
    //     customization: Customization(title: "GoRide"),
    //     txRef: _ref!,
    //     isTestMode: paymentModel.value.flutterWave!.isSandBox!,
    //     redirectUrl: '${Constant.paymentCallbackURL}success',
    //     paymentPlanId: _ref!,
    //   );
    //   final ChargeResponse response = await flutterWave.charge();

    //   if (response.success!) {
    //     ShowToastDialog.showToast("Payment Successful!!");
    //     bookingModel.value.paymentStatus = true;

    //     completeOrder(response.transactionId ?? '');
    //   } else {
    //     ShowToastDialog.showToast("Your payment is ${response.status!}");
    //   }
    // }

    String? ref;

    setRef() {
      maths.Random numRef = maths.Random();
      int year = DateTime.now().year;
      int refNumber = numRef.nextInt(20000);
      if (Platform.isAndroid) {
        ref = "AndroidRef$year$refNumber";
      } else if (Platform.isIOS) {
        ref = "IOSRef$year$refNumber";
      }
    }

    // ::::::::::::::::::::::::::::::::::::::::::::PayStack::::::::::::::::::::::::::::::::::::::::::::::::::::

    // payStackPayment(String totalAmount) async {
    //   await PayStackURLGen.payStackURLGen(
    //           amount: (double.parse(totalAmount) * 100).toString(),
    //           currency: "NGN",
    //           secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
    //           userModel: userModel.value)
    //       .then((value) async {
    //     if (value != null) {
    //       PayStackUrlModel payStackModel = value;
    //       Get.to(PayStackScreen(
    //         secretKey: paymentModel.value.payStack!.payStackSecret.toString(),
    //         callBackUrl: Constant.paymentCallbackURL.toString(),
    //         initialURl: payStackModel.data.authorizationUrl,
    //         amount: totalAmount,
    //         reference: payStackModel.data.reference,
    //       ))!
    //           .then((value) {
    //         if (value) {
    //           ShowToastDialog.showToast("Payment Successful!!");
    //           bookingModel.value.paymentStatus = "cash";

    //           completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
    //         } else {
    //           ShowToastDialog.showToast("Payment UnSuccessful!!");
    //         }
    //       });
    //     } else {
    //       ShowToastDialog.showToast(
    //           "Something went wrong, please contact admin.");
    //     }
    //   });
    // }

    // ::::::::::::::::::::::::::::::::::::::::::::Mercado Pago::::::::::::::::::::::::::::::::::::::::::::::::::::

    // mercadoPagoMakePayment(
    //     {required BuildContext context, required String amount}) {
    //   makePreference(amount).then((result) async {
    //     try {
    //       if (result.isNotEmpty) {
    //         log(result.toString());
    //         if (result['status'] == 200) {
    //           var preferenceId = result['response']['id'];
    //           log(preferenceId);

    //           Get.to(MercadoPagoScreen(
    //                   initialURl: result['response']['init_point']))!
    //               .then((value) {
    //             log(value);

    //             if (value) {
    //               ShowToastDialog.showToast("Payment Successful!");
    //               bookingModel.value.paymentStatus = "cash";

    //               completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
    //             } else {
    //               ShowToastDialog.showToast("Payment failed!");
    //             }
    //           });
    //           // final bool isDone = await Navigator.push(context, MaterialPageRoute(builder: (context) => MercadoPagoScreen(initialURl: result['response']['init_point'])));
    //         } else {
    //           ShowToastDialog.showToast("Error while transaction!");
    //         }
    //       } else {
    //         ShowToastDialog.showToast("Error while transaction!");
    //       }
    //     } catch (e) {
    //       ShowToastDialog.showToast("Something went wrong.");
    //     }
    //   });
    // }

    Future<Map<String, dynamic>> makePreference(String amount) async {
      final mp = MP.fromAccessToken(
          paymentModel.value.mercadoPago!.mercadoPagoAccessToken);
      var pref = {
        "items": [
          {
            "title": "Wallet TopUp",
            "quantity": 1,
            "unit_price": double.parse(amount)
          }
        ],
        "auto_return": "all",
        "back_urls": {
          "failure": "${Constant.paymentCallbackURL}/failure",
          "pending": "${Constant.paymentCallbackURL}/pending",
          "success": "${Constant.paymentCallbackURL}/success"
        },
      };

      var result = await mp.createPreference(pref);
      return result;
    }

    // ::::::::::::::::::::::::::::::::::::::::::::Pay Fast::::::::::::::::::::::::::::::::::::::::::::::::::::

    // payFastPayment({required BuildContext context, required String amount}) {
    //   PayStackURLGen.getPayHTML(
    //           payFastSettingData: paymentModel.value.payFast!,
    //           amount: amount.toString(),
    //           userModel: userModel.value)
    //       .then((String? value) async {
    //     bool isDone = await Get.to(PayFastScreen(
    //         htmlData: value!, payFastSettingData: paymentModel.value.payFast!));
    //     if (isDone) {
    //       Get.back();
    //       ShowToastDialog.showToast("Payment successfully");
    //       bookingModel.value.paymentStatus = "cash";

    //       completeOrder(DateTime.now().millisecondsSinceEpoch.toString());
    //     } else {
    //       Get.back();
    //       ShowToastDialog.showToast("Payment Failed");
    //     }
    //   });
    // }
  }
}
