import 'package:flutter_easyloading/flutter_easyloading.dart';

class ShowToastDialog {
  static showToast(String? message,
      {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    EasyLoading.showToast(message!, toastPosition: position);
  }

  // static showToast(String? message,
  //     {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
  //   if (message == null) return; // Add a check to prevent null messages.
  //   EasyLoading.showToast(message, toastPosition: position);
  // }

  static showLoader(String message) {
    EasyLoading.show(status: message);
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }
}
