// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:customer/app/models/user_model.dart';
import 'package:customer/app/routes/app_pages.dart';
import 'package:customer/constant/api_constant.dart';
import 'package:customer/constant_widgets/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController extends GetxController {
  //TODO: Implement EditProfileController
  RxString profileImage = "https://avatar.iran.liara.run/public".obs;
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  // TextEditingController datePickerController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  RxInt selectedGender = 1.obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;
  final ImagePicker imagePicker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  UserData? userModel;
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
    const String url = '$baseURL$getUserPofileEndpoint';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      ShowToastDialog.showLoader("Getting profile details...".tr);
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)["data"];

        name.value = data['name'] ?? '';
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        dobController.text = data['date_of_birth'] != null
            ? DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(data['date_of_birth']))
                .toString()
            : '';
        selectedGender.value = data['gender'] == 'male' ? 1 : 2;
        profileImage.value = ("$imageBaseUrl${data['profile']}") ?? '';

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("name", data['name'] ?? '');
        preferences.setString("phone_number", data['phone'] ?? '');

        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error getting profile: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('Error occurred while getting profile.')),
      );
    }
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

// update user Profile
  Future<void> updateUserProfile(
    String token,
  ) async {
    const String url = '$baseURL$updatePofileEndpoint';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final Map<String, String> payload = {
      "name": nameController.text,
      "email": emailController.text,
      "date_of_birth": dobController.text,
      "gender": selectedGender.value == 1 ? "male" : "female",
    };

    try {
      ShowToastDialog.showLoader("Completing profile...".tr);
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        log('-----update--user-----$data');
        // Handle the successful response as needed
        ShowToastDialog.closeLoader();
        Get.offAllNamed(Routes.HOME);
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text('Profile completed successfully!')),
        );
      } else {
        ShowToastDialog.closeLoader();
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
// Upload Profile function
  Future<void> uploadProfile(String token) async {
    // Check if the profile image path is not empty
    if (profileImage.value.isEmpty) {
      print('No image selected');
      return;
    }
    try {
      ShowToastDialog.showLoader("Uploading profile...".tr);
      // Read the image file as bytes
      File imageFile = File(profileImage.value);
      List<int> imageBytes = await imageFile.readAsBytes();

      // Convert the image to a base64 string
      String base64Image = base64Encode(imageBytes);

      // Create the request body
      Map<String, dynamic> body = {
        "profile": 'data:image/jpeg;base64,$base64Image',
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      // Send the POST request
      final response = await http.put(
        Uri.parse('$baseURL/users/profile/upload'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(body),
      );
      // Log the response status
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status']) {
          ShowToastDialog.closeLoader();
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: Text(data['msg'])),
          );
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("profile", data['data']);
          Get.offAllNamed(Routes.HOME);
        } else {
          ShowToastDialog.closeLoader();
          throw Exception(data['msg']);
        }
      } else {
        ShowToastDialog.closeLoader();
        throw Exception(
            'Failed to upload profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      debugPrint('Error uploading profile: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('Error occurred while uploading profile: $e'),
        ),
      );
    }
  }

  // update Profile

  profileUpdation(String token) async {
    // final Map<String, String> payload = {
    //   "name": nameController.text,
    //   "gender": selectedGender.value == 1 ? "Male" : "Female",
    //   "date_of_birth": dobController.text,
    //   "email": emailController.text
    // };
    // try {
    //   ShowToastDialog.showLoader("Update profile...".tr);
    //
    //   final http.Response response = await http.put(
    //     Uri.parse(baseURL + updloadProfileImageEndpoint),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'token': token,
    //     },
    //     body: jsonEncode(payload),
    //   );
    //
    //   final Map<String, dynamic> data = jsonDecode(response.body);
    //
    //   if (data['status'] == true && data['data'] != null) {
    //     UserData userModel = UserData();
    //
    //     userModel.id = data['data']['_id'];
    //     userModel.name = data['data']['name'];
    //     userModel.referralCode = data['data']['referral_code'];
    //
    //
    //     log('------profileUpdation------$data');
    //     // You can proceed with further operations like saving the user model or updating UI
    //     print('User data loaded successfully');
    //     ShowToastDialog.closeLoader();
    //   } else {
    //     // Handle the error case
    //     print(data['msg']); // Example: "Please sign in to continue."
    //   }
    // } catch (e) {
    //   ShowToastDialog.closeLoader();
    //   debugPrint('Error while update: $e');
    //   ScaffoldMessenger.of(Get.context!).showSnackBar(
    //     const SnackBar(
    //         content: Text('Error occurred while uploading profile.')),
    //   );
    // }
  }
}
