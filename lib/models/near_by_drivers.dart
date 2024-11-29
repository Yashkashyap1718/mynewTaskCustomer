
// Model for the main response
class NearbyDriversResponse {
  final bool status;
  final String msg;
  final List<Driver> data;
  final String rideId;

  NearbyDriversResponse({
    required this.status,
    required this.msg,
    required this.data,
    required this.rideId,
  });

  // Factory method to create object from JSON
  factory NearbyDriversResponse.fromJson(Map<String, dynamic> json) {
    return NearbyDriversResponse(
      status: json['status'],
      msg: json['msg'],
      data: List<Driver>.from(json['data'].map((x) => Driver.fromJson(x))),
      rideId: json['ride_id'],
    );
  }

  // Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'ride_id': rideId,
    };
  }
}

// Model for Driver
class Driver {
  final String id;
  final String name;
  final String role;
  final Location location;

  Driver({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
  });

  // Factory method to create Driver from JSON
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      location: Location.fromJson(json['location']),
    );
  }

  // Method to convert Driver object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'location': location.toJson(),
    };
  }
}

// Model for Location (Geo-Coordinates)
class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  // Factory method to create Location from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }

  // Method to convert Location object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

