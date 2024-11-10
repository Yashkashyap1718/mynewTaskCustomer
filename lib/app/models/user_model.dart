import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? fullName;
  String? slug;
  String? id;
  String? email;
  String? loginType;
  String? profilePic;
  String? dateOfBirth;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  String? totalEarning;
  String? gender;
  String? referralCode;

  bool? isActive;
  Timestamp? createdAt;
  String? status;
  String? role;
  String? verified;
  String? suspend;
  List<String>? languages;

  UserModel(
      {this.fullName,
      this.slug,
      this.id,
      this.isActive,
      this.dateOfBirth,
      this.email,
      this.loginType,
      this.profilePic,
      this.fcmToken,
      this.referralCode,
      this.countryCode,
      this.phoneNumber,
      this.walletAmount,
      this.totalEarning,
      this.createdAt,
      this.status,
      this.role,
      this.suspend,
      this.languages,
      this.verified,
      this.gender});

  @override
  String toString() {
    return 'UserModel{fullName: $fullName,slug: $slug, id: $id, email: $email, loginType: $loginType, profilePic: $profilePic, dateOfBirth: $dateOfBirth, fcmToken: $fcmToken, countryCode: $countryCode, phoneNumber: $phoneNumber, walletAmount: $walletAmount,totalEarning: $totalEarning, gender: $gender, isActive: $isActive, referralCode: $referralCode , createdAt: $createdAt, status: $status, role:$role, verified: $verified, suspend: $suspend, language: $languages }';
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'] ?? "";
    slug = json['slug'];
    id = json['id'] ?? 0;
    email = json['email'] ?? "example@gmail.com";
    loginType = json['loginType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'] ?? "0";
    totalEarning = json['totalEarning'] ?? "0";
    createdAt = json['createdAt'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'] ?? '';
    isActive = json['isActive'];
    referralCode = json['referralCode'] ?? "";
    status = json['status'] ?? "";
    role = json['role'] ?? "";
    suspend = json['suspend'] ?? "";
    languages = List<String>.from(json['languages'] ?? []);
    verified = json['verified'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['slug'] = slug;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['totalEarning'] = totalEarning;
    data['createdAt'] = createdAt;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    data['isActive'] = isActive;
    data['referralCode'] = referralCode;
    data['status'] = status;
    data['role'] = role;
    data['suspend'] = suspend;
    data['languages'] = languages;
    data['verified'] = verified;
    return data;
  }
}
