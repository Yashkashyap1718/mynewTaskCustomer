class RideBooking {
  final String id;
  final String vehicleId;
  final String pickupAddress;
  final Location pickupLocation;
  final String dropoffAddress;
  final Location dropoffLocation;
  final String distance;
  final String fareAmount;
  final String durationInMinutes;
  final String? paymentStatus;
  final String paymentMode;
  final String otp;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final int createdAt;
  final Passenger passenger;
  final Driver driver;
  final Vehicle vehicle;

  RideBooking({
    required this.id,
    required this.vehicleId,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.dropoffAddress,
    required this.dropoffLocation,
    required this.distance,
    required this.fareAmount,
    required this.durationInMinutes,
    this.paymentStatus,
    required this.paymentMode,
    required this.otp,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.createdAt,
    required this.passenger,
    required this.driver,
    required this.vehicle,
  });

  factory RideBooking.fromJson(Map<String, dynamic> json) {
    return RideBooking(
      id: json['_id'] ?? '',
      vehicleId: (json['vehicle_id'] is Map) ? json['vehicle_id']['_id'] ?? '' : json['vehicle_id'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      pickupLocation: Location.fromJson(json['pickup_location'] ?? {}),
      dropoffAddress: json['dropoff_address'] ?? '',
      dropoffLocation: Location.fromJson(json['dropoff_location'] ?? {}),
      distance: json['distance']?.toString() ?? '',
      fareAmount: json['fare_amount']?.toString() ?? '',
      durationInMinutes: json['duration_in_minutes']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString(),
      paymentMode: json['payment_mode'] ?? '',
      otp: json['otp']?.toString() ?? '',
      status: json['status'] ?? '',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime(0),
      endTime:
          json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      createdAt: json['createdAt'] ?? 0,
      passenger: Passenger.fromJson(json['passenger'] ?? {}),
      driver: Driver.fromJson(json['driver'] ?? {}),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vehicle_id': vehicleId,
      'pickup_address': pickupAddress,
      'pickup_location': {
        'type': pickupLocation.type,
        'coordinates': pickupLocation.coordinates,
      },
      'dropoff_address': dropoffAddress, 
      'dropoff_location': {
        'type': dropoffLocation.type,
        'coordinates': dropoffLocation.coordinates,
      },
      'distance': distance,
      'fare_amount': fareAmount,
      'duration_in_minutes': durationInMinutes,
      'payment_status': paymentStatus,
      'payment_mode': paymentMode,
      'otp': otp,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'createdAt': createdAt,
      'passenger': {
        '_id': passenger.id,
        'name': passenger.name,
        'email': passenger.email,
        'phone': passenger.phone,
        'location': {
          'type': passenger.location.type,
          'coordinates': passenger.location.coordinates,
        },
        'profile': passenger.profile,
        'gender': passenger.gender,
        'ride_status': passenger.rideStatus,
        'push_notification': passenger.pushNotification,
        'createdAt': passenger.createdAt,
      },
      'driver': {
        'id': driver.id,
        'name': driver.name,
        'email': driver.email,
        'phone': driver.phone,
      },
      'vehicle': {
        'id': vehicle.type,
        'type': vehicle.type,
        'model': vehicle.model,
        'number': vehicle.vehicleNumber,
      },
    };
  }



  get vehicleType => null;
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
    );
  }
}

class Passenger {
  final String id;
  final String? name;
  final String email;
  final String phone;
  final Location location;
  final String profile;
  final String? gender;
  final String rideStatus;
  final String pushNotification;
  final int createdAt;

  Passenger({
    required this.id,
    this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.profile,
    this.gender,
    required this.rideStatus,
    required this.pushNotification,
    required this.createdAt,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['_id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      profile: json['profile']?.toString() ?? '',
      gender: json['gender'],
      rideStatus: json['ride_status'] ?? '',
      pushNotification: json['push_notification'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }
}

class Driver {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final Location location;
  final String profile;
  final String gender;
  final String rideStatus;
  final String pushNotification;
  final int createdAt;

  Driver({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.location,
    required this.profile,
    required this.gender,
    required this.rideStatus,
    required this.pushNotification,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      profile: json['profile']?.toString() ?? '',
      gender: json['gender'] ?? '',
      rideStatus: json['ride_status'] ?? '',
      pushNotification: json['push_notification'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }
}

class Vehicle {
  final String name;
  final String model;
  final String vehicleNumber;
  final String color;
  final String type;
  final String image;
  final int createdAt;

  Vehicle({
    required this.name,
    required this.model,
    required this.vehicleNumber,
    required this.color,
    required this.type,
    required this.image,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      color: json['color'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }
}
