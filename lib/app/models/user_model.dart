// class UserModel {
//   String? fullName;
//   String? slug;
//   String? id;
//   String? email;
//   String? loginType;
//   String? profilePic;
//   String? dateOfBirth;
//   String? fcmToken;
//   String? countryCode;
//   String? phoneNumber;
//   String? walletAmount;
//   String? totalEarning;
//   String? gender;
//   String? referralCode;
//   bool? isActive;
//   Timestamp? createdAt;
//   String? status;
//   String? role;
//   String? verified;
//   String? suspend;
//   List<String>? languages;
//
//   UserModel(
//       {this.fullName,
//       this.slug,
//       this.id,
//       this.isActive,
//       this.dateOfBirth,
//       this.email,
//       this.loginType,
//       this.profilePic,
//       this.fcmToken,
//       this.referralCode,
//       this.countryCode,
//       this.phoneNumber,
//       this.walletAmount,
//       this.totalEarning,
//       this.createdAt,
//       this.status,
//       this.role,
//       this.suspend,
//       this.languages,
//       this.verified,
//       this.gender});
//
//   @override
//   String toString() {
//     return 'UserModel{fullName: $fullName,slug: $slug, _id: $id, email: $email, loginType: $loginType, profilePic: $profilePic, dateOfBirth: $dateOfBirth, fcmToken: $fcmToken, countryCode: $countryCode, phoneNumber: $phoneNumber, walletAmount: $walletAmount,totalEarning: $totalEarning, gender: $gender, isActive: $isActive, referralCode: $referralCode , createdAt: $createdAt, status: $status, role:$role, verified: $verified, suspend: $suspend, language: $languages }';
//   }
//
//   UserModel.fromJson(Map<String, dynamic> json) {
//     fullName = json['fullName'] ?? "";
//     slug = json['slug'];
//     id = json['_id'] ?? 0;
//     email = json['email'] ?? "example@gmail.com";
//     loginType = json['loginType'];
//     profilePic = json['profilePic'];
//     fcmToken = json['fcmToken'];
//     countryCode = json['countryCode'];
//     phoneNumber = json['phoneNumber'];
//     walletAmount = json['walletAmount'] ?? "0";
//     totalEarning = json['totalEarning'] ?? "0";
//     createdAt = json['createdAt'];
//     gender = json['gender'];
//     dateOfBirth = json['dateOfBirth'] ?? '';
//     isActive = json['isActive'];
//     referralCode = json['referralCode'] ?? "";
//     status = json['status'] ?? "";
//     role = json['role'] ?? "";
//     suspend = json['suspend'] ?? "";
//     languages = List<String>.from(json['languages'] ?? []);
//     verified = json['verified'] ?? "";
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['fullName'] = fullName;
//     data['slug'] = slug;
//     data['_id'] = id;
//     data['email'] = email;
//     data['loginType'] = loginType;
//     data['profilePic'] = profilePic;
//     data['fcmToken'] = fcmToken;
//     data['countryCode'] = countryCode;
//     data['phoneNumber'] = phoneNumber;
//     data['walletAmount'] = walletAmount;
//     data['totalEarning'] = totalEarning;
//     data['createdAt'] = createdAt;
//     data['gender'] = gender;
//     data['dateOfBirth'] = dateOfBirth;
//     data['isActive'] = isActive;
//     data['referralCode'] = referralCode;
//     data['status'] = status;
//     data['role'] = role;
//     data['suspend'] = suspend;
//     data['languages'] = languages;
//     data['verified'] = verified;
//     return data;
//   }
// }
// ////////////////////////////////////////////////////////////
class UserModel {
  bool? status;
  String? msg;
  UserData? data;

  UserModel({this.status, this.msg, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? id;
  String? name;
  String? countryCode;
  String? phone;
  String? referralCode;
  bool? verified;
  String? role;
  List<String>? languages;
  String? profile;
  String? pushNotification;
  String? status;
  String? suspend;
  String? gender;
  dynamic createdAt;

  UserData(
      {this.id,
      this.name,
      this.countryCode,
      this.phone,
      this.referralCode,
      this.verified,
      this.role,
      this.languages,
      this.profile,
      this.pushNotification,
      this.status,
      this.suspend,
      this.gender,
      this.createdAt});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Hii user', // Nullable
      countryCode: json['country_code'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      referralCode: json['referral_code'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      role: json['role'] as String? ?? '',
      languages: List<String>.from(json['languages']),
      profile: json['profile'] as String? ?? '',
      pushNotification: json['push_notification'] as String? ?? '',
      status: json['status'] as String? ?? '',
      suspend: json['suspend'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      createdAt: json['createdAt'] as dynamic? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['country_code'] = countryCode;
    data['phone'] = phone;
    data['referral_code'] = referralCode;
    data['verified'] = verified;
    data['role'] = role;
    data['languages'] = languages;
    data['profile'] = profile;
    data['push_notification'] = pushNotification;
    data['status'] = status;
    data['suspend'] = suspend;
    data['gender'] = gender;
    data['createdAt'] = createdAt;
    return data;
  }
}
