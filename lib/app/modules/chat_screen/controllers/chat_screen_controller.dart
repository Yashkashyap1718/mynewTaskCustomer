// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/app/models/chat_model/chat_model.dart';
import 'package:customer/app/models/chat_model/inbox_model.dart';
import 'package:customer/app/models/driver_user_model.dart';
import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:http/http.dart' as http;


class ChatScreenController extends GetxController {
  Rx<UserData> senderUserModel = UserData().obs;
  Rx<DriverUserModel> receiverUserModel = DriverUserModel().obs;
  RxList<ChatModel> chatList = <ChatModel>[].obs;
  final messageTextEditorController = TextEditingController().obs;
  RxString message = "".obs;
  RxBool isLoading = true.obs;

  String receiverId = "";
  String rideID = "";
  String driverId = "";
  Timer? timer;


  @override
  void onInit() {
    super.onInit();

    if(Get.arguments != null){
      receiverId = Get.arguments["receiverId"];
      rideID = Get.arguments["rideID"];
      driverId = Get.arguments["driverId"];
      getData(receiverId);
    }
    timer =  Timer.periodic(Duration(seconds: 10), (timer) {

      findChat(rideID,driverId);
    });
    addDummyData();

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getData(String receiverId) async {
    await FireStoreUtils.getDriverUserProfile(receiverId).then((value) {
      receiverUserModel.value = value!;
    });
      senderUserModel.value = userDataModel;
    isLoading.value = false;



    getRiderAndDriverChat(rideID,driverId);


  }
  static Future getRiderAndDriverChat(String rideId,driverId) async {
    ShowToastDialog.showToast("Please wait".tr);
    final response = await http.post(
      Uri.parse(baseURL + createChat),
      body: jsonEncode({'ride_id':rideId,'driver_id':driverId}),
      headers: {"Content-Type": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["status"]) {
        print("response.body:::::  ${jsonDecode(response.body)["status"]}");
        findChat(rideId,driverId);
      }else{
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Something went wrong");
      }
    } else {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong");
    }
  }

  static Future findChat(String rideID, String driverId) async {
    // Construct the URL with query parameters
    final Uri uri = Uri.parse(baseURL + findDriverChat).replace(
      queryParameters: {
        'ride_id': rideID,
        'driver_id': driverId,
      },
    );

    // Perform the GET request
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "token": token,
      },
    );
    print("response.body:::::findDriverChat  ${jsonDecode(response.body)}");

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["status"]) {

      } else {
        ShowToastDialog.showToast("Something went wrong");
      }
    } else {
      ShowToastDialog.showToast("Something went wrong");
    }
  }

  void sendMessageAPI(String message) async{
    ShowToastDialog.showToast("Please wait".tr);
    final response = await http.post(
      Uri.parse(baseURL + sendMessageAPIHttp),
      body: jsonEncode({'chat_id':rideID,'message':message}),
      headers: {"Content-Type": "application/json", "token": token},
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)["status"]) {
          messageTextEditorController.value.clear();
        print("response.body:::::findDriverChat  ${jsonDecode(response.body)["status"]}");

      }else{
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Something went wrong");
      }
    } else {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong");
    }
  }



  sendMessage() async {
    InboxModel inboxModel = InboxModel(
        archive: false,
        lastMessage: messageTextEditorController.value.text.trim(),
        mediaUrl: "",
        receiverId: receiverUserModel.value.id.toString(),
        seen: false,
        senderId: senderUserModel.value.id.toString(),
        timestamp: Timestamp.now(),
        type: "text");

    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(senderUserModel.value.id.toString())
        .collection("inbox")
        .doc(receiverUserModel.value.id.toString())
        .set(inboxModel.toJson());

    await FireStoreUtils.fireStore
        .collection(CollectionName.chat)
        .doc(receiverUserModel.value.id.toString())
        .collection("inbox")
        .doc(senderUserModel.value.id.toString())
        .set(inboxModel.toJson());

    // ChatModel chatModel = ChatModel(
        // type: "text",
        // timestamp: Timestamp.now(),
        // senderId: senderUserModel.value.id.toString(),
        // seen: false,
        // receiverId: receiverUserModel.value.id.toString(),
        // mediaUrl: "",
        // chatID: Constant.getUuid(),
        // message: messageTextEditorController.value.text.trim());

    message.value = messageTextEditorController.value.text;
    messageTextEditorController.value.clear();

    // await FireStoreUtils.fireStore
    //     .collection(CollectionName.chat)
    //     .doc(senderUserModel.value.id.toString())
    //     .collection(receiverUserModel.value.id.toString())
    //     .doc(chatModel.chatID)
    //     .set(chatModel.toJson());
    // await FireStoreUtils.fireStore
    //     .collection(CollectionName.chat)
    //     .doc(receiverUserModel.value.id.toString())
    //     .collection(senderUserModel.value.id.toString())
    //     .doc(chatModel.chatID)
    //     .set(chatModel.toJson());

    Map<String, dynamic> playLoad = <String, dynamic>{
      "type": "chat",
      "senderId": senderUserModel.value.id.toString(),
      "receiverId": receiverUserModel.value.id.toString(),
    };
 String   fcmToken = await FirebaseMessaging.instance.getToken()??"";
 if(fcmToken==""){
   return;
 }

    await SendNotification.sendOneNotification(
      type: "chat",
      token: fcmToken.toString(),
      title: senderUserModel.value.name.toString(),
      body: message.value,
      payload: playLoad,
    );

    message.value = "";
  }

  void addDummyData() {
    // chatList.add(ChatModel(chatID:"2" ,mediaUrl:"" ,message: "Hello",receiverId: "2",seen: true,senderId:"673d6dc42c10cc7f1648d0cc" ,timestamp: Timestamp.fromDate(DateTime.now()),type: ""));
    // chatList.add(ChatModel(chatID:"1" ,mediaUrl:"" ,message: "Hii",receiverId: "1",seen: true,senderId:"2" ,timestamp: Timestamp.fromDate(DateTime.now()),type: ""));
    // update();
  }


}
