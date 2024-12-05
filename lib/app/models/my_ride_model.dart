class MyRideModel {
  String? id;
  String? orderId;
  String? pickupAddress;
  Location? pickupLocation;
  String? dropoffAddress;
  Location? dropoffLocation;
  String? distance;
  String? fareAmount;
  String? durationInMinutes;
  String? status;
  String? otp;
  String? couponId;
  String? paymentStatus;
  String? paymentMode;
  DateTime? startTime;
  DateTime? endTime;
  String? remainingTime;
  int? createdAt;
  Passenger? passenger;
  Driver? driver;
  Vehicle? vehicle;

  MyRideModel({
    this.id,
    this.orderId,
    this.pickupAddress,
    this.pickupLocation,
    this.dropoffAddress,
    this.dropoffLocation,
    this.distance,
    this.fareAmount,
    this.durationInMinutes,
    this.status,
    this.otp,
    this.couponId,
    this.paymentStatus,
    this.paymentMode,
    this.startTime,
    this.endTime,
    this.remainingTime,
    this.createdAt,
    this.passenger,
    this.driver,
    this.vehicle,
  });

  factory MyRideModel.fromJson(Map<String, dynamic> json) {
    return MyRideModel(
      id: json['_id'],
      orderId: json['order_id'],
      pickupAddress: json['pickup_address'],
      pickupLocation: Location.fromJson(json['pickup_location']),
      dropoffAddress: json['dropoff_address'],
      dropoffLocation: Location.fromJson(json['dropoff_location']),
      distance: json['distance'],
      fareAmount: json['fare_amount'],
      durationInMinutes: json['duration_in_minutes'],
      status: json['status'],
      otp: json['otp'],
      couponId: json['coupon_id'],
      paymentStatus: json['payment_status'],
      paymentMode: json['payment_mode'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      remainingTime: json['remaining_time'],
      createdAt: json['createdAt'],
      passenger: json['passenger'] != null
          ? Passenger.fromJson(json['passenger'])
          : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
    );
  }
}

class Location {
  String type;
  List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}

class Passenger {
  String id;
  String name;
  String email;
  String phone;
  String profile;
  String gender;
  int createdAt;

  Passenger({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profile,
    required this.gender,
    required this.createdAt,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profile: json['profile'],
      gender: json['gender'],
      createdAt: json['createdAt'],
    );
  }
}

class Driver {
  String id;
  String? name;
  String? email;
  String? phone;
  String? profile;
  String? gender;
  String? createdAt;

  Driver({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.profile,
    this.gender,
    this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profile: json['profile'],
      gender: json['gender'],
      createdAt: json['createdAt'],
    );
  }
}

class Vehicle {
  String id;
  String name;
  String model;
  String vehicleNumber;
  String vehicleColor;
  String vehicleType;
  String image;
  String status;
  int createdAt;

  Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.vehicleNumber,
    required this.vehicleColor,
    required this.vehicleType,
    required this.image,
    required this.status,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      name: json['name'],
      model: json['model'],
      vehicleNumber: json['vehicle_number'],
      vehicleColor: json['vehicle_color'],
      vehicleType: json['vehicle_type'],
      image: json['image'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
