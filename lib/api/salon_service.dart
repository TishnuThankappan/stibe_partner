import 'package:stibe_partner/api/api_service.dart';

class SalonDto {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String openingTime;  // Keep as string for display
  final String closingTime;  // Keep as string for display
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalonDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.openingTime,
    required this.closingTime,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalonDto.fromJson(Map<String, dynamic> json) {
    return SalonDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      openingTime: _formatTimeSpan(json['openingTime']),
      closingTime: _formatTimeSpan(json['closingTime']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isActive: json['isActive'] ?? true,
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static String _formatTimeSpan(dynamic timeSpan) {
    if (timeSpan == null) return '09:00';
    
    // Handle different formats from API
    if (timeSpan is String) {
      if (timeSpan.contains(':')) {
        return timeSpan.substring(0, 5); // Take HH:mm
      }
      return timeSpan;
    }
    
    // Handle TimeSpan object
    return timeSpan.toString().substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phoneNumber': phoneNumber,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateSalonRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String openingTime; // Format: "09:00:00"
  final String closingTime; // Format: "18:00:00"
  final double? currentLatitude;
  final double? currentLongitude;
  final bool useCurrentLocation;

  CreateSalonRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    this.openingTime = "09:00:00",
    this.closingTime = "18:00:00",
    this.currentLatitude,
    this.currentLongitude,
    this.useCurrentLocation = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'Name': name,  // PascalCase for .NET API
      'Description': description,
      'Address': address,
      'City': city,
      'State': state,
      'ZipCode': zipCode,
      'PhoneNumber': phoneNumber,
      'OpeningTime': openingTime,
      'ClosingTime': closingTime,
      'CurrentLatitude': currentLatitude,
      'CurrentLongitude': currentLongitude,
      'UseCurrentLocation': useCurrentLocation,
    };
  }
}

class SalonService {
  final ApiService _apiService = ApiService();

  // Create a new salon
  Future<SalonDto> createSalon(CreateSalonRequest request) async {
    print('🏢 Creating salon with SalonService');
    print('📤 Request: ${request.toJson()}');
    
    final response = await _apiService.post('/salon', data: request.toJson());
    
    print('📥 Salon creation response: $response');
    
    if (response['data'] != null) {
      return SalonDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to create salon: ${response['message'] ?? 'Unknown error'}');
  }

  // Get salon by ID
  Future<SalonDto> getSalonById(int salonId) async {
    final response = await _apiService.get('/salon/$salonId');
    
    if (response['data'] != null) {
      return SalonDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get salon');
  }
  // Get current user's salons
  Future<List<SalonDto>> getMySalons() async {
    final response = await _apiService.get('/salon');
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((salon) => SalonDto.fromJson(salon))
          .toList();
    }
    
    return [];
  }
}