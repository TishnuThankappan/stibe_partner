class User {
  final int id;  // Changed to int to match .NET API
  final String email;
  final String phoneNumber;
  final String firstName;  // Separated firstName and lastName
  final String lastName;
  final String? profileImage;
  final String role;
  final bool isEmailVerified;  // Added to match .NET API
  final DateTime createdAt;
  final Business? business;

  User({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    this.business,
  });

  // Helper getter for full name
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
      role: json['role'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      business: json['business'] != null
          ? Business.fromJson(json['business'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'business': business?.toJson(),
    };
  }
}

class Business {
  final String id;
  final String name;
  final String address;
  final String? description;
  final String? logo;
  final List<String>? photos;
  final String? website;
  final List<OpeningHours> openingHours;
  final Location location;
  final List<String> serviceCategories;
  final bool isVerified;
  final DateTime createdAt;

  Business({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    this.logo,
    this.photos,
    this.website,
    required this.openingHours,
    required this.location,
    required this.serviceCategories,
    required this.isVerified,
    required this.createdAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      logo: json['logo'],
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : null,
      website: json['website'],
      openingHours: (json['openingHours'] as List)
          .map((hour) => OpeningHours.fromJson(hour))
          .toList(),
      location: Location.fromJson(json['location']),
      serviceCategories: List<String>.from(json['serviceCategories']),
      isVerified: json['isVerified'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'logo': logo,
      'photos': photos,
      'website': website,
      'openingHours': openingHours.map((hour) => hour.toJson()).toList(),
      'location': location.toJson(),
      'serviceCategories': serviceCategories,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OpeningHours {
  final String day;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  OpeningHours({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      day: json['day'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      isClosed: json['isClosed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
