// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:customer/app/models/user_model.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:customer/extension/string_extensions.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../utils/database_helper.dart';

class EditProfileController extends GetxController {
  //TODO: Implement EditProfileController

  RxString profileImage =
      "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23"
          .obs;
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  RxInt selectedGender = 1.obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  final ImagePicker imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  @override
  void onInit() {
    getUserData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getUserData() async {
    UserModel? userModel =
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    if (userModel != null) {
      profileImage.value = (userModel.profilePic ?? "").isNotEmpty
          ? userModel.profilePic ??
              "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23"
          : "https://firebasestorage.googleapis.com/v0/b/mytaxi-a8627.appspot.com/o/constant_assets%2F59.png?alt=media&token=a0b1aebd-9c01-45f6-9569-240c4bc08e23";
      name.value = userModel.fullName ?? '';
      nameController.text = userModel.fullName ?? '';
      phoneNumber.value =
          (userModel.countryCode ?? '') + (userModel.phoneNumber ?? '');
      phoneNumberController.text = (userModel.phoneNumber ?? '');
      emailController.text = (userModel.email ?? '');
    }
  }

  saveUserData() async {
    UserModel? userModel =
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
    userModel!.gender = selectedGender.value == 1 ? "Male" : "Female";
    userModel.fullName = nameController.text;
    userModel.slug = nameController.text.toSlug(delimiter: "-");
    ShowToastDialog.showLoader("Please wait".tr);
    if (profileImage.value.isNotEmpty &&
        Constant().hasValidUrl(profileImage.value) == false) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "profileImage/${FireStoreUtils.getCurrentUid()}",
        File(profileImage.value).path.split('/').last,
      );
    }
    userModel.profilePic = profileImage.value;
    await FireStoreUtils.updateUser(userModel);
    ShowToastDialog.closeLoader();
    Get.back(result: true);
  }

  Future<void> pickFile(
      {required ImageSource source, required String token}) async {
    try {
      XFile? image =
          await imagePicker.pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      Get.back();

      // Compress the image using flutter_image_compress
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 50,
      );

      // Save the compressed image to a new file
      File compressedFile = File(image.path);
      await compressedFile.writeAsBytes(compressedBytes!);

      profileImage.value = compressedFile.path;
      uploadProfile(token);

      log('----image----${profileImage.value}');
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }

// complete SignUp Profile
  Future<void> completeSignupProfile(String token, String referralCode) async {
    const String url = '$baseURL/users/complete';

    final Map<String, String> payload = {
      "name": nameController.text,
      "gender": selectedGender.value == 1 ? "Male" : "Female",
      "referral_code": referralCode,
    };

    try {
      ShowToastDialog.showLoader("Completing profile...".tr);

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Handle the successful response as needed
        ShowToastDialog.closeLoader();
        Get.back(
            result: true); // Optionally navigate back or show a success message
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('Profile completed successfully!')),
        );
      } else {
        throw Exception('Failed to complete signup profile');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error completing profile: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
            content: Text('Error occurred while completing profile.')),
      );
    }
  }

  // Upload Profile
  Future<void> uploadProfile(String token) async {
    const String url = '$baseURL/users/profile/upload';

    // Check if the profile image path is not empty
    if (profileImage.value.isEmpty) {
      print('No image selected');
      return;
    }

    try {
      ShowToastDialog.showLoader("Uploading profile...".tr);

      // Create a multipart request
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add headers to the request
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'token': token,
      });

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'profile', // The name of the field in your backend for the image
        profileImage.value,
      ));

      // Send the request
      final http.StreamedResponse response = await request.send();

      // Process the response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);

        if (data['status']) {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: Text(data['msg'])),
          );
        } else {
          throw Exception(data['msg']);
        }
      } else {
        throw Exception('Failed to upload profile');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error uploading profile: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
            content: Text('Error occurred while uploading profile.')),
      );
    }
  }

  // update Profile

  profileUpdation(String token) async {
    final Map<String, String> payload = {
      "name": nameController.text,
      "gender": selectedGender.value == 1 ? "Male" : "Female",
      "date_of_birth": dobController.text,
      "email": emailController.text
    };
    try {
      ShowToastDialog.showLoader("Update profile...".tr);

      final http.Response response = await http.post(
        Uri.parse(baseURL + updatePofileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == true && data['data'] != null) {
        UserModel userModel = UserModel();

        userModel.id = data['data']['_id'];
        userModel.fullName = data['data']['name'];
        userModel.gender = data['data']['gender'];
        userModel.referralCode = data['data']['referral_code'];
        userModel.dateOfBirth = data['data']['date_of_birth'];
        userModel.email = data['data']['email'];
        userModel.profilePic = data['data']['profile'];

        DatabaseHelper().insertUser(userModel);

        // You can proceed with further operations like saving the user model or updating UI
        print('User data loaded successfully');
        ShowToastDialog.closeLoader();
      } else {
        // Handle the error case
        print(data['msg']); // Example: "Please sign in to continue."
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error while update: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
            content: Text('Error occurred while uploading profile.')),
      );
    }
  }
}
