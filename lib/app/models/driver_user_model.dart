

class DriverUserModel {
  String? id;
  String? fullName;
  String? profilePic;
  String? countryCode;
  String? phoneNumber;
  String? walletAmount;
  String? totalEarning;
  String? gender;
  Location? location;
  bool? isActive;
  bool? isOnline;
  bool? isVerified;
  bool? suspend;
  String? createdAt;
  DriverVehicleDetails? driverVehicleDetails;
  dynamic rotation;
  dynamic reviewsCount;
  dynamic reviewsSum;
  List<dynamic>? driverdDocs;

  DriverUserModel(
      {this.id,
        this.fullName,
        this.profilePic,
        this.countryCode,
        this.phoneNumber,
        this.walletAmount,
        this.totalEarning,
        this.gender,
        this.location,
        this.isActive,
        this.isOnline,
        this.isVerified,
        this.suspend,
        this.createdAt,
        this.driverVehicleDetails,
        this.rotation,
        this.reviewsCount,
        this.reviewsSum,
        this.driverdDocs});

  DriverUserModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    profilePic = json['profilePic'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    walletAmount = json['walletAmount'];
    totalEarning = json['totalEarning'];
    gender = json['gender'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    isActive = json['isActive'];
    isOnline = json['isOnline'];
    isVerified = json['isVerified'];
    suspend = json['suspend'];
    createdAt = json['createdAt'];
    driverVehicleDetails = json['driverVehicleDetails'] != null
        ? DriverVehicleDetails.fromJson(json['driverVehicleDetails'])
        : null;
    rotation = json['rotation'];
    reviewsCount = json['reviewsCount'];
    reviewsSum = json['reviewsSum'];
    if (json['driverdDocs'] != null) {
      driverdDocs = <dynamic>[];
      json['driverdDocs'].forEach((v) {
        // driverdDocs!.add(new dynamic.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['fullName'] = fullName;
    data['profilePic'] = profilePic;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['walletAmount'] = walletAmount;
    data['totalEarning'] = totalEarning;
    data['gender'] = gender;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['isActive'] = isActive;
    data['isOnline'] = isOnline;
    data['isVerified'] = isVerified;
    data['suspend'] = suspend;
    data['createdAt'] = createdAt;
    if (driverVehicleDetails != null) {
      data['driverVehicleDetails'] = driverVehicleDetails!.toJson();
    }
    data['rotation'] = rotation;
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    if (driverdDocs != null) {
      data['driverdDocs'] = driverdDocs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class DriverVehicleDetails {
  String? userId;
  String? vehicleTypeName;
  String? vehicleTypeId;
  String? brandName;
  String? brandId;
  String? modelName;
  String? modelId;
  String? vehicleNumber;
  String? vehicleColor;
  String? status;
  bool? isVerified;
  String? image;

  DriverVehicleDetails(
      {this.userId,
        this.vehicleTypeName,
        this.vehicleTypeId,
        this.brandName,
        this.brandId,
        this.modelName,
        this.modelId,
        this.vehicleNumber,
        this.vehicleColor,
        this.status,
        this.isVerified,
        this.image});

  DriverVehicleDetails.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    vehicleTypeName = json['vehicleTypeName'];
    vehicleTypeId = json['vehicleTypeId'];
    brandName = json['brandName'];
    brandId = json['brandId'];
    modelName = json['modelName'];
    modelId = json['modelId'];
    vehicleNumber = json['vehicleNumber'];
    vehicleColor = json['vehicleColor'];
    status = json['status'];
    isVerified = json['isVerified'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['vehicleTypeName'] = vehicleTypeName;
    data['vehicleTypeId'] = vehicleTypeId;
    data['brandName'] = brandName;
    data['brandId'] = brandId;
    data['modelName'] = modelName;
    data['modelId'] = modelId;
    data['vehicleNumber'] = vehicleNumber;
    data['vehicleColor'] = vehicleColor;
    data['status'] = status;
    data['isVerified'] = isVerified;
    data['image'] = image;
    return data;
  }
}




// class DriverUserModel {
//   String? id;
//   String? fullName;
//   String? profilePic;
//   String? countryCode;
//   String? phoneNumber;
//   String? walletAmount;
//   String? totalEarning;
//   String? gender;
//   bool? isActive;
//   bool? isOnline;
//   bool? isVerified;
//   bool? suspend;
//   String? createdAt;
//   DriverVehicleDetails? driverVehicleDetails;
//   dynamic? rotation;
//   dynamic? reviewsCount;
//   dynamic? reviewsSum;
//   List<dynamic>? driverdDocs;
//
//   DriverUserModel(
//       {this.id,
//         this.fullName,
//         this.profilePic,
//         this.countryCode,
//         this.phoneNumber,
//         this.walletAmount,
//         this.totalEarning,
//         this.gender,
//         this.isActive,
//         this.isOnline,
//         this.isVerified,
//         this.suspend,
//         this.createdAt,
//         this.driverVehicleDetails,
//         this.rotation,
//         this.reviewsCount,
//         this.reviewsSum,
//         this.driverdDocs});
//
//   DriverUserModel.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     fullName = json['fullName'];
//     profilePic = json['profilePic'];
//     countryCode = json['countryCode'];
//     phoneNumber = json['phoneNumber'];
//     walletAmount = json['walletAmount'];
//     totalEarning = json['totalEarning'];
//     gender = json['gender'];
//     isActive = json['isActive'];
//     isOnline = json['isOnline'];
//     isVerified = json['isVerified'];
//     suspend = json['suspend'];
//     createdAt = json['createdAt'];
//     driverVehicleDetails = json['driverVehicleDetails'] != null
//         ? new DriverVehicleDetails.fromJson(json['driverVehicleDetails'])
//         : null;
//     rotation = json['rotation'];
//     reviewsCount = json['reviewsCount'];
//     reviewsSum = json['reviewsSum'];
//     if (json['driverdDocs'] != null) {
//       driverdDocs = <dynamic>[];
//
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.id;
//     data['fullName'] = this.fullName;
//     data['profilePic'] = this.profilePic;
//     data['countryCode'] = this.countryCode;
//     data['phoneNumber'] = this.phoneNumber;
//     data['walletAmount'] = this.walletAmount;
//     data['totalEarning'] = this.totalEarning;
//     data['gender'] = this.gender;
//     data['isActive'] = this.isActive;
//     data['isOnline'] = this.isOnline;
//     data['isVerified'] = this.isVerified;
//     data['suspend'] = this.suspend;
//     data['createdAt'] = this.createdAt;
//     if (this.driverVehicleDetails != null) {
//       data['driverVehicleDetails'] = this.driverVehicleDetails!.toJson();
//     }
//     data['rotation'] = this.rotation;
//     data['reviewsCount'] = this.reviewsCount;
//     data['reviewsSum'] = this.reviewsSum;
//     if (this.driverdDocs != null) {
//       data['driverdDocs'] = this.driverdDocs!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class DriverVehicleDetails {
//   String? userId;
//   String? vehicleTypeName;
//   String? vehicleTypeId;
//   String? brandName;
//   String? brandId;
//   String? modelName;
//   String? modelId;
//   String? vehicleNumber;
//   String? vehicleColor;
//   String? status;
//   bool? isVerified;
//   String? image;
//
//   DriverVehicleDetails(
//       {this.userId,
//         this.vehicleTypeName,
//         this.vehicleTypeId,
//         this.brandName,
//         this.brandId,
//         this.modelName,
//         this.modelId,
//         this.vehicleNumber,
//         this.vehicleColor,
//         this.status,
//         this.isVerified,
//         this.image});
//
//   DriverVehicleDetails.fromJson(Map<String, dynamic> json) {
//     userId = json['user_id'];
//     vehicleTypeName = json['vehicleTypeName'];
//     vehicleTypeId = json['vehicleTypeId'];
//     brandName = json['brandName'];
//     brandId = json['brandId'];
//     modelName = json['modelName'];
//     modelId = json['modelId'];
//     vehicleNumber = json['vehicleNumber'];
//     vehicleColor = json['vehicleColor'];
//     status = json['status'];
//     isVerified = json['isVerified'];
//     image = json['image'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['user_id'] = this.userId;
//     data['vehicleTypeName'] = this.vehicleTypeName;
//     data['vehicleTypeId'] = this.vehicleTypeId;
//     data['brandName'] = this.brandName;
//     data['brandId'] = this.brandId;
//     data['modelName'] = this.modelName;
//     data['modelId'] = this.modelId;
//     data['vehicleNumber'] = this.vehicleNumber;
//     data['vehicleColor'] = this.vehicleColor;
//     data['status'] = this.status;
//     data['isVerified'] = this.isVerified;
//     data['image'] = this.image;
//     return data;
//   }
// }
