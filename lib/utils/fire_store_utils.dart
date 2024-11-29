import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/models/banner_model.dart';
import 'package:customer/app/models/booking_model.dart';
import 'package:customer/app/models/coupon_model.dart';
import 'package:customer/app/models/currencies_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/language_model.dart';
import 'package:customer/app/models/notification_model.dart';
import 'package:customer/app/models/payment_method_model.dart';
import 'package:customer/app/models/review_customer_model.dart';
import 'package:customer/app/models/support_reason_model.dart';
import 'package:customer/app/models/support_ticket_model.dart';
import 'package:customer/app/models/tax_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/app/models/wallet_transaction_model.dart';
import 'package:customer/constant/booking_status.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer/constant/api_constant.dart';


class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      isLogin = true;
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  // static Future<UserData?> getUserProfile() async {
  //   UserData? userModel;
  //   try {
  //     ShowToastDialog.showLoader("Please wait".tr);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString("token");
  //     final response = await http.get(
  //       Uri.parse(baseURL + getUserPofileEndpoint),
  //       headers: {
  //         'token': token.toString(),
  //       },
  //     );
  //     // Check if the response status is OK
  //     if (response.statusCode == 200) {
  //       ShowToastDialog.closeLoader();
  //       final jsonResponse = jsonDecode(response.body);
  //       // Check if the response status is true
  //       if (jsonResponse['status'] == true) {
  //         userModel = UserData.fromJson(jsonResponse['data']);
  //         return userModel;
  //       } else {
  //         ShowToastDialog.closeLoader();
  //         log("Failed to fetch user profile: ${jsonResponse['msg']}");
  //       }
  //     } else {
  //       ShowToastDialog.closeLoader();
  //       log("Error: ${response.statusCode} - ${response.reasonPhrase}");
  //     }
  //   } catch (error) {
  //     ShowToastDialog.closeLoader();
  //   }
  //   return null;
  //   // return userModel;
  // }

  static Future<UserData?> getUserProfileAPI() async {
    UserData? userModel;
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      final response = await http.get(
        Uri.parse(baseURL + getUserPofileEndpoint),
        headers: {
          'token': token.toString(),
        },
      );

      print("USERDATAAPI  ${response.body}");

      // Check if the response status is OK
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          userModel = UserData.fromJson(jsonResponse['data']);
          print("USERDATAAPI  ${jsonEncode(userModel)}");
          userDataModel = userModel;

         FirebaseMessaging messaging = FirebaseMessaging.instance;
         await messaging.subscribeToTopic(userDataModel.id!);

          return userModel;
        } else {
          ShowToastDialog.closeLoader();
          log("Failed to fetch user profile: ${jsonResponse['msg']}");
        }
      } else {
        ShowToastDialog.closeLoader();
        log("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (error) {
      ShowToastDialog.closeLoader();
    }
    return null;
    // return userModel;
  }

  // static Future<bool?> deleteUser() async {
  //   bool? isDelete;
  //   try {
  //     await fireStore
  //         .collection(CollectionName.users)
  //         .doc(FireStoreUtils.getCurrentUid())
  //         .delete();

  //     // delete user  from firebase auth
  //     await FirebaseAuth.instance.currentUser!.delete().then((value) {
  //       isDelete = true;
  //     });
  //   } catch (e, s) {
  //     log('FireStoreUtils.firebaseCreateNewUser $e $s');
  //     return false;
  //   }
  //   return isDelete;
  // }

  static Future<bool?> deleteUser(String userId, String token) async {
    bool? isDelete = false;
    final String url = "$baseURL/$userId";

    try {
      // HTTP DELETE request
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'token': token,
        },
      );

      // Check if the response status is OK
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if the deletion was successful
        if (jsonResponse['status'] == true) {
          isDelete = true;
        } else {
          log("Failed to delete user: ${jsonResponse['msg']}");
        }
      } else {
        log("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e, s) {
      log('Failed to delete user: $e $s');
    }

    return isDelete;
  }

  static Future<bool?> updateUserWallet({required String amount}) async {
    bool isAdded = false;
    // await getUserProfile().then((value) async {
    //   if (value != null) {
    //     UserData userModel = value;
    //     userModel.walletAmount =
    //         (double.parse(userModel.walletAmount.toString()) +
    //                 double.parse(amount))
    //             .toString();
    //     await FireStoreUtils.updateUser(userModel).then((value) {
    //       isAdded = value;
    //     });
    //   }
    // });
    return isAdded;
  }

  static Future<bool?> updateOtherUserWallet(
      {required String amount, required String id}) async {
    bool isAdded = false;
    await getDriverUserProfile(id).then((value) async {
      if (value != null) {
        DriverUserModel driverUserModel = value;
        driverUserModel.walletAmount =
            (double.parse(driverUserModel.walletAmount.toString()) +
                    double.parse(amount))
                .toStringAsFixed(2)
                .toString();
        driverUserModel.totalEarning =
            (double.parse(driverUserModel.totalEarning.toString()) +
                    double.parse(amount))
                .toStringAsFixed(2)
                .toString();
        await FireStoreUtils.updateDriverUser(driverUserModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await fireStore
        .collection(CollectionName.currency)
        .where("active", isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  getSettings() async {
    await fireStore
        .collection(CollectionName.settings)
        .doc("constant")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.mapAPIKey = value.data()!["googleMapKey"];
        Constant.senderId = value.data()!["notification_senderId"];
        Constant.jsonFileURL = value.data()!["jsonFileURL"];
        Constant.minimumAmountToWithdrawal =
            value.data()!["minimum_amount_withdraw"];
        Constant.minimumAmountToDeposit =
            value.data()!["minimum_amount_deposit"];
        Constant.appName = value.data()!["appName"];
        Constant.appColor = value.data()!["appColor"];
        Constant.termsAndConditions = value.data()!["termsAndConditions"];
        Constant.privacyPolicy = value.data()!["privacyPolicy"];
        Constant.aboutApp = value.data()!["aboutApp"];
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("globalValue")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.distanceType = value.data()!["distanceType"];
        Constant.driverLocationUpdate = value.data()!["driverLocationUpdate"];
        Constant.radius = value.data()!["radius"];
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("canceling_reason")
        .get()
        .then((value) {
      if (value.exists) {
        Constant.cancellationReason = value.data()!["reasons"];
      }
    });

    // await fireStore.collection(CollectionName.settings).doc("global").get().then((value) {
    //   if (value.exists) {
    //     Constant.termsAndConditions = value.data()!["termsAndConditions"];
    //     Constant.privacyPolicy = value.data()!["privacyPolicy"];
    //     // Constant.appVersion = value.data()!["appVersion"];
    //   }
    // });

    // await fireStore
    //     .collection(CollectionName.settings)
    //     .doc("admin_commission")
    //     .get()
    //     .then((value) {
    //   AdminCommission adminCommission = AdminCommission.fromJson(value.data()!);
    //   if (adminCommission.active == true) {
    //     Constant.adminCommission = adminCommission;
    //   }
    // });

    // await fireStore.collection(CollectionName.settings).doc("referral").get().then((value) {
    //   if (value.exists) {
    //     Constant.referralAmount = value.data()!["referralAmount"];
    //   }
    // });
    //
    // await fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
    //   if (value.exists) {
    //     Constant.supportURL = value.data()!["supportURL"];
    //   }
    // });
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("payment")
        .get()
        .then((value) {
      // paymentModel = PaymentModel.fromJson(value.data()!);
      // Constant.paymentModel = PaymentModel.fromJson(value.data()!);
    });
    // print("Payment Data : ${json.encode(paymentModel!.toJson().toString())}");
    return paymentModel;
  }

  static Future<List<VehicleTypeModel>?> getVehicleType() async {
    List<VehicleTypeModel> vehicleTypeList = [];
    await fireStore
        .collection(CollectionName.vehicleType)
        .where("isActive", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VehicleTypeModel vehicleTypeModel =
            VehicleTypeModel.fromJson(element.data());
        vehicleTypeList.add(vehicleTypeModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return vehicleTypeList;
  }

  Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];

    await fireStore
        .collection(CollectionName.countryTax)
        .where('country', isEqualTo: Constant.country)
        .where('active', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return taxList;
  }

  static Future<List<CouponModel>?> getCoupon() async {
    List<CouponModel> couponList = [];
    await fireStore
        .collection(CollectionName.coupon)
        .where("active", isEqualTo: true)
        .where("isPrivate", isEqualTo: false)
        .where('expireAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel couponModel = CouponModel.fromJson(element.data());
        couponList.add(couponModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return couponList;
  }




  static Future<RideRequest?> checkforRealTimebooking(
      BookingModel bookingModel) async {
    RideRequest? data;
    final response = await http.get(
      Uri.parse(baseURL + realtimeRequest),
      headers: {"Content-Type": "application/json", "token": token},
    );

    if (response.statusCode == 200) {
      data = RideRequest.fromJson(jsonDecode(response.body));

      // return jsonDecode(response.body);
    } else {
      log("Failed to add ride:");
    }

    return data;

    // await fireStore
    //     .collection(CollectionName.bookings)
    //     .doc(bookingModel.id)
    //     .set(bookingModel.toJson())
    //     .then((value) {
    //   isAdded = true;
    // }).catchError((error) {
    //   log("Failed to add ride: $error");
    //   isAdded = false;
    // });
  }

  StreamController<List<DriverUserModel>>? getNearestDriverController;

  Future<RideRequest> sendOrderData(RideRequest bookingModel) async {
    getNearestDriverController =
        StreamController<List<DriverUserModel>>.broadcast();

    List<DriverUserModel> ordersList = [];
    List<String> driverIdList = [];

    // DriverUserModel driverUserModel = DriverUserModel.fromJson(data);
    // ordersList.add(driverUserModel);
    // if (driverUserModel.fcmToken != null &&
    //     !driverIdList.contains(driverUserModel.id)) {
    //   driverIdList.add(driverUserModel.id ?? '');
    //   Map<String, dynamic> playLoad = <String, dynamic>{
    //     "bookingId": bookingModel.data.id
    //   };
    //   await SendNotification.sendOneNotification(
    //       type: "order",
    //       token: driverUserModel.fcmToken.toString(),
    //       title: 'New Ride Available'.tr,
    //       body: 'A customer has placed an ride near your location.'.tr,
    //       bookingId: bookingModel.data.id,
    //       senderId: FireStoreUtils.getCurrentUid(),
    //       payload: playLoad);
    // }

    if (!getNearestDriverController!.isClosed) {
      getNearestDriverController!.sink.add(ordersList);
    }

    log("------>$getNearestDriverController");
    getNearestDriverController!.close();
    log("------>${getNearestDriverController!.isClosed}");
    return bookingModel;
  }

  closeStream() {
    log("------>$getNearestDriverController");
    if (getNearestDriverController != null) {
      log("==================>getNearestDriverController.close()");
      getNearestDriverController == null;
      getNearestDriverController!.close();
    }
  }

  StreamController<List<BookingModel>>? getHomeOngoingBookingController;

  Stream<List<BookingModel>> getHomeOngoingBookings() async* {
    getHomeOngoingBookingController =
        StreamController<List<BookingModel>>.broadcast();
    List<BookingModel> bookingsList = [];
    String customerId = getCurrentUid();
    Stream<QuerySnapshot> stream1 = fireStore
        .collection(CollectionName.bookings)
        .where('bookingStatus', whereIn: [
          BookingStatus.bookingAccepted,
          BookingStatus.bookingPlaced,
          BookingStatus.bookingOngoing
        ])
        .where("customerId", isEqualTo: customerId)
        .orderBy("createAt", descending: true)
        .snapshots();
    stream1.listen((QuerySnapshot querySnapshot) {
      log("Length= : ${querySnapshot.docs.length}");
      bookingsList.clear();
      for (var document in querySnapshot.docs) {
        final data = document.data() as Map<String, dynamic>;
        BookingModel bookingModel = BookingModel.fromJson(data);
        bookingsList.add(bookingModel);
      }
      // final closetsDateTimeToNow = bookingsList.reduce((a, b) =>
      //     (a.bookingTime!).toDate().difference(DateTime.now()).abs() <
      //             (b.bookingTime!).toDate().difference(DateTime.now()).abs()
      //         ? a
      //         : b);

      getHomeOngoingBookingController!.sink.add(bookingsList);
    });

    yield* getHomeOngoingBookingController!.stream;
  }

  closeHomeOngoingStream() {
    if (getHomeOngoingBookingController != null) {
      getHomeOngoingBookingController!.close();
    }
  }

  StreamController<BookingModel>? getBookingStatusController;

  Stream<BookingModel> getBookingStatusData(String bookingId) async* {
    RideRequest? data;
    // final response = await http.get(
    //   Uri.parse(baseURL + realtimeRequest),
    //   headers: {
    //     "Content-Type": "application/json",
    //     "token":
    //         token
    //   },
    // );

    // if (response.statusCode == 200) {
    //   data = RideRequest.fromJson(jsonDecode(response.body));

    //   // return jsonDecode(response.body);
    // } else {
    //   log("Failed to add ride:");
    // }

    // BookingModel bookingModel = BookingModel.fromJson(data);
    //       if ((data!.status ?? '') ==
    //           BookingStatus.bookingOngoing) {
    //         ShowToastDialog.showToast("Your ride started...");
    //         // Get.offAll(const HomeView());
    //         Get.back();
    //         // Get.toNamed(Routes.HOME);
    //       } else {}
    //       if (!getBookingStatusController!.isClosed) {
    //         getBookingStatusController!.sink.add(bookingModel);
    //       }
    yield* getBookingStatusController!.stream;
  }

  closeBookingStatusStream() {
    if (getBookingStatusController != null) {
      getBookingStatusController == null;
      getBookingStatusController!.close();
    }
  }

  static Future<BookingModel?> getRideDetails(String bookingId) async {
    BookingModel? bookingModel;
    await fireStore
        .collection(CollectionName.bookings)
        .where("id", isEqualTo: bookingId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        bookingModel = BookingModel.fromJson(element.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return bookingModel;
  }

  static Future<List<BookingModel>> getOngoingRides() async {
    List<BookingModel> bookingList = [];

    try {
      ShowToastDialog.showLoader("Please wait".tr);

      final response = await http.post(
        Uri.parse(baseURL + acceptedRide),
        headers: {"Content-Type": "application/json", "token": token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          // Map the raw data to BookingModel objects
          bookingList = (responseData['data'] as List)
              .map((item) => BookingModel.fromJson(item))
              .toList();
        } else {
          ShowToastDialog.closeLoader();
        }
      } else {
        ShowToastDialog.closeLoader();
      }
    } catch (error) {
      ShowToastDialog.closeLoader();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
    return bookingList;
  }

  static Future<List<BookingModel>> getCompletedRides() async {
    List<BookingModel> bookingList = [];

    try {
      ShowToastDialog.showLoader("Please wait".tr);

      final response = await http.post(
        Uri.parse(baseURL + completedRide),
        headers: {"Content-Type": "application/json", "token": token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          // Map the raw data to BookingModel objects
          bookingList = (responseData['data'] as List)
              .map((item) => BookingModel.fromJson(item))
              .toList();
        } else {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                  responseData['msg'] ?? "Failed to fetch completed rides"),
            ),
          );
        }
      } else {
        ShowToastDialog.closeLoader();
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Server error. Please try again later."),
          ),
        );
      }
    } catch (error) {
      ShowToastDialog.closeLoader();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }

    ShowToastDialog.closeLoader(); // Ensure loader is closed
    return bookingList;
  }

  static Future<List<BookingModel>?> getRejectedRides() async {
    log('*********getRejectedRides-----call');
    List<BookingModel> bookingList = [];

    try {
      ShowToastDialog.showLoader("Please wait".tr);

      final response = await http.post(
        Uri.parse(baseURL + canceledRide),
        headers: {"Content-Type": "application/json", "token": token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          // Map the raw data to BookingModel objects
          bookingList = (responseData['data'] as List)
              .map((item) => BookingModel.fromJson(item))
              .toList();
        } else {
          ShowToastDialog.closeLoader();
        }
      } else {
        ShowToastDialog.closeLoader();
      }
    } catch (error) {
      ShowToastDialog.closeLoader();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
    return bookingList;
  }

  static Future<DriverUserModel?> getDriverUserProfile(String uuid) async {
    DriverUserModel? userModel;
    userModel = await getOnlineUserModel(uuid);
    return userModel;
  }

  static Future<DriverUserModel> getOnlineUserModel(String uuid) async {
    final response = await http.post(
      Uri.parse(baseURL + getDriverDetails),
      body: jsonEncode({'driver_id': uuid}),
      headers: {"Content-Type": "application/json", "token": token},
    );

    print("response.body:::::  ${response.body}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["status"]) {
        print("response.body:::::  ${jsonDecode(response.body)["status"]}");

        return DriverUserModel.fromJson(jsonDecode(response.body)['data']);
      }
      return DriverUserModel();
    } else {
      return DriverUserModel();
    }
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    log("====> 3");
    await fireStore
        .collection(CollectionName.walletTransaction)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModelList = [];

    await fireStore
        .collection(CollectionName.walletTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('type', isEqualTo: "customer")
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionModelList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModelList;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore
        .collection(CollectionName.review)
        .doc(orderId)
        .get()
        .then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.review)
        .doc(reviewModel.id)
        .set(reviewModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool> updateDriverUser(DriverUserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.drivers)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<NotificationModel>?> getNotificationList() async {
    List<NotificationModel> notificationModel = [];
    await fireStore
        .collection(CollectionName.notification)
        .where('customerId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        NotificationModel taxModel = NotificationModel.fromJson(element.data());
        notificationModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return notificationModel;
  }

  static Future<bool?> setNotification(
      NotificationModel notificationModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.notification)
        .doc(notificationModel.id)
        .set(notificationModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<BannerModel>?> getBannerList() async {
    List<BannerModel> bannerList = [];
    await fireStore
        .collection(CollectionName.banner)
        .where("isEnable", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        BannerModel bannerModel = BannerModel.fromJson(element.data());
        bannerList.add(bannerModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return bannerList;
  }

  static Future<List<LanguageModel>> getLanguage() async {
    List<LanguageModel> languageModelList = [];
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection(CollectionName.languages)
        .get();
    for (var document in snap.docs) {
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        languageModelList.add(LanguageModel.fromJson(data));
      } else {
        print('getLanguage is null ');
      }
    }
    return languageModelList;
  }

  static Future<List<SupportReasonModel>> getSupportReason() async {
    List<SupportReasonModel> supportReasonList = [];
    await fireStore
        .collection(CollectionName.supportReason)
        .where("type", isEqualTo: "customer")
        .get()
        .then((value) {
      for (var element in value.docs) {
        SupportReasonModel supportReasonModel =
            SupportReasonModel.fromJson(element.data());
        supportReasonList.add(supportReasonModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return supportReasonList;
  }

  static Future<bool> addSupportTicket(
      SupportTicketModel supportTicketModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.supportTicket)
        .doc(supportTicketModel.id)
        .set(supportTicketModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to add Support Ticket : $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<SupportTicketModel>> getSupportTicket(String id) async {
    List<SupportTicketModel> supportTicketList = [];
    await fireStore
        .collection(CollectionName.supportTicket)
        .where("userId", isEqualTo: id)
        .orderBy("createAt", descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        SupportTicketModel supportTicketModel =
            SupportTicketModel.fromJson(element.data());
        supportTicketList.add(supportTicketModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return supportTicketList;
  }
}

// Main model class
class RideRequest {
  bool status;
  String msg;
  RideData data;

  RideRequest({
    required this.status,
    required this.msg,
    required this.data,
  });

  // Factory method to create an instance from JSON
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      status: json['status'],
      msg: json['msg'],
      data: RideData.fromJson(json['data']),
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'data': data.toJson(),
    };
  }
}

// Data class that represents the details of the ride request
class RideData {
  Locationn pickupLocation;
  Locationn dropoffLocation;
  String id;
  String passengerId;
  String? driverId;
  String? vehicleId;
  String? vehicleTypeId;
  String pickupAddress;
  String dropoffAddress;
  String distance;
  FareAmount fareAmount;
  double durationInMinutes;
  String status;
  String? couponId;
  String? otp;
  String paymentStatus;
  String paymentMode;
  int? startTime;
  int? endTime;
  int? remainingTime;
  int createdAt;
  int updatedAt;
  int v;

  RideData({
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.id,
    required this.passengerId,
    this.driverId,
    this.vehicleId,
    this.vehicleTypeId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.distance,
    required this.fareAmount,
    required this.durationInMinutes,
    required this.status,
    this.couponId,
    this.otp,
    required this.paymentStatus,
    required this.paymentMode,
    this.startTime,
    this.endTime,
    this.remainingTime,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  // Factory method to create an instance from JSON
  factory RideData.fromJson(Map<String, dynamic> json) {
    return RideData(
      pickupLocation: Locationn.fromJson(json['pickup_location']),
      dropoffLocation: Locationn.fromJson(json['dropoff_location']),
      id: json['_id'],
      passengerId: json['passenger_id'],
      driverId: json['driver_id'],
      vehicleId: json['vehicle_id'],
      vehicleTypeId: json['vehicle_type_id'],
      pickupAddress: json['pickup_address'],
      dropoffAddress: json['dropoff_address'],
      distance: json['distance'],
      fareAmount: FareAmount.fromJson(json['fare_amount']),
      durationInMinutes: json['duration_in_minutes'].toDouble(),
      status: json['status'],
      couponId: json['coupon_id'],
      otp: json['otp'],
      paymentStatus: json['payment_status'],
      paymentMode: json['payment_mode'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      remainingTime: json['remaining_time'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pickup_location': pickupLocation.toJson(),
      'dropoff_location': dropoffLocation.toJson(),
      '_id': id,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'vehicle_type_id': vehicleTypeId,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'distance': distance,
      'fare_amount': fareAmount.toJson(),
      'duration_in_minutes': durationInMinutes,
      'status': status,
      'coupon_id': couponId,
      'otp': otp,
      'payment_status': paymentStatus,
      'payment_mode': paymentMode,
      'start_time': startTime,
      'end_time': endTime,
      'remaining_time': remainingTime,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

// Model class for a location (Point)
class Locationn {
  String type;
  List<double> coordinates;

  Locationn({
    required this.type,
    required this.coordinates,
  });

  // Factory method to create an instance from JSON
  factory Locationn.fromJson(Map<String, dynamic> json) {
    return Locationn(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

// Model class for fare amount
class FareAmount {
  String numberDecimal;

  FareAmount({required this.numberDecimal});

  // Factory method to create an instance from JSON
  factory FareAmount.fromJson(Map<String, dynamic> json) {
    return FareAmount(
      numberDecimal: json['\$numberDecimal'],
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      '\$numberDecimal': numberDecimal,
    };
  }
}
