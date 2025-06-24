import 'package:stibe_partner/api/api_service.dart';

class StaffDto {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final int salonId;
  final String? specialization;
  final double? hourlyRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.salonId,
    this.specialization,
    this.hourlyRate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffDto.fromJson(Map<String, dynamic> json) {
    return StaffDto(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      salonId: json['salonId'],
      specialization: json['specialization'],
      hourlyRate: json['hourlyRate']?.toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'salonId': salonId,
      'specialization': specialization,
      'hourlyRate': hourlyRate,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class StaffRegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final int salonId;
  final String? specialization;
  final double? hourlyRate;

  StaffRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.salonId,
    this.specialization,
    this.hourlyRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
      'salonId': salonId,
      'specialization': specialization,
      'hourlyRate': hourlyRate,
    };
  }
}

class StaffUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? specialization;
  final double? hourlyRate;

  StaffUpdateRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.specialization,
    this.hourlyRate,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (specialization != null) data['specialization'] = specialization;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
    return data;
  }
}

class StaffDashboardDto {
  final int totalAppointments;
  final int todayAppointments;
  final double totalEarnings;
  final double todayEarnings;
  final List<dynamic> recentAppointments;
  final Map<String, dynamic> performanceMetrics;

  StaffDashboardDto({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.recentAppointments,
    required this.performanceMetrics,
  });

  factory StaffDashboardDto.fromJson(Map<String, dynamic> json) {
    return StaffDashboardDto(
      totalAppointments: json['totalAppointments'] ?? 0,
      todayAppointments: json['todayAppointments'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      recentAppointments: json['recentAppointments'] ?? [],
      performanceMetrics: json['performanceMetrics'] ?? {},
    );
  }
}

class StaffService {
  final ApiService _apiService = ApiService();

  // Register new staff member
  Future<StaffDto> registerStaff(StaffRegisterRequest request) async {
    final response = await _apiService.post('/staff/register', data: request.toJson());
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to register staff');
  }

  // Staff login
  Future<StaffDto> staffLogin({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/staff/login', data: {
      'email': email,
      'password': password,
    });

    // Save token
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      return StaffDto.fromJson(data['user'] ?? data);
    }

    throw Exception('Staff login failed');
  }

  // Get staff dashboard
  Future<StaffDashboardDto> getStaffDashboard() async {
    final response = await _apiService.get('/staff/dashboard');
    
    if (response['data'] != null) {
      return StaffDashboardDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get dashboard data');
  }

  // Get staff profile
  Future<StaffDto> getStaffProfile() async {
    final response = await _apiService.get('/staff/profile');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get staff profile');
  }

  // Update staff profile
  Future<StaffDto> updateStaffProfile(StaffUpdateRequest request) async {
    final response = await _apiService.put('/staff/profile', data: request.toJson());
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update staff profile');
  }

  // Add staff specializations
  Future<bool> addSpecializations(List<String> specializations) async {
    try {
      final response = await _apiService.post('/staff/specializations', data: {
        'specializations': specializations,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get staff by salon ID
  Future<List<StaffDto>> getStaffBySalon(int salonId) async {
    final response = await _apiService.get('/staff/salon/$salonId');
    
    if (response['data'] != null) {
      return (response['data'] as List)
          .map((staff) => StaffDto.fromJson(staff))
          .toList();
    }
    
    return [];
  }

  // Get specific staff member
  Future<StaffDto> getStaffById(int staffId) async {
    final response = await _apiService.get('/staff/$staffId');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get staff details');
  }
}
