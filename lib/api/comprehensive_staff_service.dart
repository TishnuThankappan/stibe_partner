import 'package:stibe_partner/api/api_service.dart';

// ===================================================================
// STAFF DATA MODELS
// ===================================================================

class StaffDto {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final String bio;
  final String? photoUrl;
  final bool isActive;
  
  // Schedule
  final String startTime; // "09:00:00"
  final String endTime; // "17:00:00"
  final String lunchBreakStart; // "13:00:00"
  final String lunchBreakEnd; // "14:00:00"
  
  // Professional
  final int experienceYears;
  final double hourlyRate;
  final double commissionRate;
  final String employmentType;
  
  // Performance
  final double averageRating;
  final int totalReviews;
  final int totalServices;
  
  // Salon
  final int salonId;
  final String salonName;
  
  // Additional
  final String certifications;
  final String languages;
  final String instagramHandle;
  
  final DateTime joinDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.bio,
    this.photoUrl,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.lunchBreakStart,
    required this.lunchBreakEnd,
    required this.experienceYears,
    required this.hourlyRate,
    required this.commissionRate,
    required this.employmentType,
    required this.averageRating,
    required this.totalReviews,
    required this.totalServices,
    required this.salonId,
    required this.salonName,
    required this.certifications,
    required this.languages,
    required this.instagramHandle,
    required this.joinDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  List<String> get certificationsAsList {
    if (certifications.isEmpty) return [];
    try {
      return certifications.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      return [certifications];
    }
  }

  List<String> get languagesAsList {
    if (languages.isEmpty) return [];
    try {
      return languages.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      return [languages];
    }
  }

  factory StaffDto.fromJson(Map<String, dynamic> json) {
    return StaffDto(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      bio: json['bio'] ?? '',
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
      startTime: _formatTimeSpan(json['startTime']),
      endTime: _formatTimeSpan(json['endTime']),
      lunchBreakStart: _formatTimeSpan(json['lunchBreakStart']),
      lunchBreakEnd: _formatTimeSpan(json['lunchBreakEnd']),
      experienceYears: json['experienceYears'] ?? 0,
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      commissionRate: (json['commissionRate'] ?? 0).toDouble(),
      employmentType: json['employmentType'] ?? 'Full-Time',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalServices: json['totalServices'] ?? 0,
      salonId: json['salonId'] ?? 0,
      salonName: json['salonName'] ?? '',
      certifications: json['certifications'] ?? '',
      languages: json['languages'] ?? '',
      instagramHandle: json['instagramHandle'] ?? '',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static String _formatTimeSpan(dynamic timeSpan) {
    if (timeSpan == null) return '09:00:00';
    
    if (timeSpan is String) {
      if (timeSpan.contains(':')) {
        // Ensure format is HH:mm:ss
        List<String> parts = timeSpan.split(':');
        if (parts.length == 2) {
          return '${parts[0]}:${parts[1]}:00';
        }
        return timeSpan;
      }
      return timeSpan;
    }
    
    return timeSpan.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'bio': bio,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'startTime': startTime,
      'endTime': endTime,
      'lunchBreakStart': lunchBreakStart,
      'lunchBreakEnd': lunchBreakEnd,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'commissionRate': commissionRate,
      'employmentType': employmentType,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalServices': totalServices,
      'salonId': salonId,
      'salonName': salonName,
      'certifications': certifications,
      'languages': languages,
      'instagramHandle': instagramHandle,
      'joinDate': joinDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class StaffRegistrationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;
  final String bio;
  final int salonId;
  final String startTime;
  final String endTime;
  final String lunchBreakStart;
  final String lunchBreakEnd;
  final int experienceYears;
  final double hourlyRate;
  final double commissionRate;
  final String employmentType;
  final String certifications;
  final String languages;
  final String instagramHandle;

  StaffRegistrationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    this.bio = '',
    required this.salonId,
    this.startTime = '09:00:00',
    this.endTime = '17:00:00',
    this.lunchBreakStart = '13:00:00',
    this.lunchBreakEnd = '14:00:00',
    this.experienceYears = 0,
    this.hourlyRate = 0.0,
    this.commissionRate = 40.0,
    this.employmentType = 'Full-Time',
    this.certifications = '',
    this.languages = '',
    this.instagramHandle = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
      'bio': bio,
      'salonId': salonId,
      'startTime': startTime,
      'endTime': endTime,
      'lunchBreakStart': lunchBreakStart,
      'lunchBreakEnd': lunchBreakEnd,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'commissionRate': commissionRate,
      'employmentType': employmentType,
      'certifications': certifications,
      'languages': languages,
      'instagramHandle': instagramHandle,
    };
  }
}

class StaffUpdateRequest {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? role;
  final String? bio;
  final String? photoUrl;
  final bool? isActive;
  final String? startTime;
  final String? endTime;
  final String? lunchBreakStart;
  final String? lunchBreakEnd;
  final int? experienceYears;
  final double? hourlyRate;
  final double? commissionRate;
  final String? employmentType;
  final String? certifications;
  final String? languages;
  final String? instagramHandle;

  StaffUpdateRequest({
    required this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.role,
    this.bio,
    this.photoUrl,
    this.isActive,
    this.startTime,
    this.endTime,
    this.lunchBreakStart,
    this.lunchBreakEnd,
    this.experienceYears,
    this.hourlyRate,
    this.commissionRate,
    this.employmentType,
    this.certifications,
    this.languages,
    this.instagramHandle,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (role != null) data['role'] = role;
    if (bio != null) data['bio'] = bio;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (isActive != null) data['isActive'] = isActive;
    if (startTime != null) data['startTime'] = startTime;
    if (endTime != null) data['endTime'] = endTime;
    if (lunchBreakStart != null) data['lunchBreakStart'] = lunchBreakStart;
    if (lunchBreakEnd != null) data['lunchBreakEnd'] = lunchBreakEnd;
    if (experienceYears != null) data['experienceYears'] = experienceYears;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
    if (commissionRate != null) data['commissionRate'] = commissionRate;
    if (employmentType != null) data['employmentType'] = employmentType;
    if (certifications != null) data['certifications'] = certifications;
    if (languages != null) data['languages'] = languages;
    if (instagramHandle != null) data['instagramHandle'] = instagramHandle;
    return data;
  }
}

class StaffListResponse {
  final List<StaffDto> staff;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  StaffListResponse({
    required this.staff,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    return StaffListResponse(
      staff: (json['staff'] as List<dynamic>?)
          ?.map((item) => StaffDto.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

// ===================================================================
// COMPREHENSIVE STAFF MANAGEMENT SERVICE
// ===================================================================

class ComprehensiveStaffService {
  final ApiService _apiService = ApiService();

  // ===================== STAFF CRUD OPERATIONS =====================

  /// Get all staff members for a salon with advanced filtering
  Future<StaffListResponse> getSalonStaff(
    int salonId, {
    int page = 1,
    int pageSize = 10,
    bool includeInactive = false,
    String? searchTerm,
    String? roleFilter,
    String? sortBy, // 'name', 'joinDate', 'rating', 'experience'
    bool? ascending,
  }) async {
    print('🔧 Getting staff for salon $salonId');
    
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'includeInactive': includeInactive,
    };
    
    if (searchTerm != null && searchTerm.isNotEmpty) queryParams['search'] = searchTerm;
    if (roleFilter != null && roleFilter.isNotEmpty) queryParams['role'] = roleFilter;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (ascending != null) queryParams['ascending'] = ascending;

    final response = await _apiService.get(
      '/staff/salon/$salonId',
      queryParams: queryParams,
    );
    
    print('📥 Staff list response: $response');
    
    if (response['data'] != null) {
      return StaffListResponse.fromJson(response['data']);
    }
    
    throw Exception('Failed to get salon staff: ${response['message'] ?? 'Unknown error'}');
  }

  /// Register new staff member
  Future<StaffDto> registerStaff(StaffRegistrationRequest request) async {
    print('🔧 Registering new staff member: ${request.email}');
    
    final response = await _apiService.post('/staff/register', data: request.toJson());
    
    print('📥 Staff registration response: $response');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to register staff: ${response['message'] ?? 'Unknown error'}');
  }

  /// Get specific staff member details
  Future<StaffDto> getStaffById(int staffId) async {
    print('🔧 Getting staff member $staffId');
    
    final response = await _apiService.get('/staff/$staffId');
    
    print('📥 Staff details response: $response');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to get staff member: ${response['message'] ?? 'Unknown error'}');
  }

  /// Update staff member information
  Future<StaffDto> updateStaff(StaffUpdateRequest request) async {
    print('🔧 Updating staff member ${request.id}');
    
    final response = await _apiService.put('/staff/${request.id}', data: request.toJson());
    
    print('📥 Staff update response: $response');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update staff member: ${response['message'] ?? 'Unknown error'}');
  }

  /// Toggle staff member active status
  Future<StaffDto> toggleStaffStatus(int staffId, bool isActive) async {
    print('🔧 ${isActive ? "Activating" : "Deactivating"} staff member $staffId');
    
    final response = await _apiService.put('/staff/$staffId', data: {
      'isActive': isActive,
    });
    
    print('📥 Staff status toggle response: $response');
    
    if (response['data'] != null) {
      return StaffDto.fromJson(response['data']);
    }
    
    throw Exception('Failed to update staff status: ${response['message'] ?? 'Unknown error'}');
  }

  /// Delete/Remove staff member
  Future<void> deleteStaff(int staffId) async {
    print('🗑️ Removing staff member $staffId');
    
    final response = await _apiService.delete('/staff/$staffId');
    
    print('📥 Staff deletion response: $response');
    
    if (response['success'] != true) {
      throw Exception('Failed to remove staff member: ${response['message'] ?? 'Unknown error'}');
    }
  }

  // ===================== STAFF SCHEDULE MANAGEMENT =====================

  /// Update staff work schedule
  Future<StaffDto> updateStaffSchedule({
    required int staffId,
    required String startTime,
    required String endTime,
    required String lunchBreakStart,
    required String lunchBreakEnd,
  }) async {
    print('🔧 Updating schedule for staff $staffId');
    
    final request = StaffUpdateRequest(
      id: staffId,
      startTime: startTime,
      endTime: endTime,
      lunchBreakStart: lunchBreakStart,
      lunchBreakEnd: lunchBreakEnd,
    );
    
    return await updateStaff(request);
  }

  /// Get staff availability for specific date
  Future<Map<String, dynamic>> getStaffAvailability(int staffId, DateTime date) async {
    print('🔧 Getting availability for staff $staffId on ${date.toString()}');
    
    final response = await _apiService.get('/staff/$staffId/availability', queryParams: {
      'date': date.toIso8601String(),
    });
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    return {};
  }

  // ===================== STAFF PERFORMANCE & ANALYTICS =====================

  /// Get staff performance metrics
  Future<Map<String, dynamic>> getStaffPerformance(
    int staffId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('🔧 Getting performance for staff $staffId');
    
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    
    final response = await _apiService.get('/staff/$staffId/performance', queryParams: queryParams);
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    return {};
  }

  /// Get staff earnings report
  Future<Map<String, dynamic>> getStaffEarnings(
    int staffId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('🔧 Getting earnings for staff $staffId');
    
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    
    final response = await _apiService.get('/staff/$staffId/earnings', queryParams: queryParams);
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    return {};
  }

  /// Get staff bookings/appointments
  Future<List<Map<String, dynamic>>> getStaffBookings(
    int staffId, {
    DateTime? date,
    String? status, // 'scheduled', 'completed', 'cancelled'
  }) async {
    print('🔧 Getting bookings for staff $staffId');
    
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date.toIso8601String();
    if (status != null) queryParams['status'] = status;
    
    final response = await _apiService.get('/staff/$staffId/bookings', queryParams: queryParams);
    
    if (response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    
    return [];
  }

  // ===================== STAFF SPECIALIZATIONS =====================

  /// Add specialization to staff member
  Future<Map<String, dynamic>> addStaffSpecialization({
    required int staffId,
    required int serviceId,
    required String proficiencyLevel, // 'Beginner', 'Intermediate', 'Advanced', 'Expert'
    double serviceTimeMultiplier = 1.0,
    bool isPreferred = false,
    String? notes,
  }) async {
    print('🔧 Adding specialization to staff $staffId');
    
    final response = await _apiService.post('/staff/specializations', data: {
      'staffId': staffId,
      'serviceId': serviceId,
      'proficiencyLevel': proficiencyLevel,
      'serviceTimeMultiplier': serviceTimeMultiplier,
      'isPreferred': isPreferred,
      'notes': notes,
    });
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    throw Exception('Failed to add specialization: ${response['message'] ?? 'Unknown error'}');
  }

  /// Get staff specializations
  Future<List<Map<String, dynamic>>> getStaffSpecializations(int staffId) async {
    print('🔧 Getting specializations for staff $staffId');
    
    final response = await _apiService.get('/staff/$staffId/specializations');
    
    if (response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    
    return [];
  }

  // ===================== BULK OPERATIONS =====================

  /// Update multiple staff members' status
  Future<Map<String, dynamic>> bulkUpdateStaffStatus({
    required List<int> staffIds,
    required bool isActive,
  }) async {
    print('🔧 Bulk updating ${staffIds.length} staff members status to $isActive');
    
    final response = await _apiService.put('/staff/bulk/status', data: {
      'staffIds': staffIds,
      'isActive': isActive,
    });
    
    if (response['data'] != null) {
      return response['data'];
    }
    
    throw Exception('Failed to bulk update staff status: ${response['message'] ?? 'Unknown error'}');
  }

  // ===================== UTILITY METHODS =====================

  /// Get available staff roles
  static List<String> getAvailableRoles() {
    return [
      'Manager',
      'Senior Stylist',
      'Stylist', 
      'Junior Stylist',
      'Colorist',
      'Nail Technician',
      'Aesthetician',
      'Massage Therapist',
      'Barber',
      'Receptionist',
      'Assistant',
    ];
  }

  /// Get employment types
  static List<String> getEmploymentTypes() {
    return [
      'Full-Time',
      'Part-Time',
      'Contract',
      'Freelance',
      'Intern',
    ];
  }

  /// Get proficiency levels
  static List<String> getProficiencyLevels() {
    return [
      'Beginner',
      'Intermediate', 
      'Advanced',
      'Expert',
    ];
  }

  /// Format time for display
  static String formatTime(String timeString) {
    try {
      if (timeString.contains(':')) {
        List<String> parts = timeString.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          
          String period = hour >= 12 ? 'PM' : 'AM';
          int displayHour = hour % 12;
          if (displayHour == 0) displayHour = 12;
          
          return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  /// Parse time from display format to API format
  static String parseTimeToApiFormat(String displayTime) {
    try {
      if (displayTime.contains('AM') || displayTime.contains('PM')) {
        String period = displayTime.contains('AM') ? 'AM' : 'PM';
        String time = displayTime.replaceAll(RegExp(r'[AP]M'), '').trim();
        
        List<String> parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
        
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
      }
      
      // If already in 24-hour format, ensure seconds are included
      if (displayTime.contains(':')) {
        List<String> parts = displayTime.split(':');
        if (parts.length == 2) {
          return '${parts[0]}:${parts[1]}:00';
        }
      }
      
      return displayTime;
    } catch (e) {
      return displayTime;
    }
  }

  /// Generate random staff avatar color
  static String getStaffAvatarColor(String name) {
    final colors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
      '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9',
    ];
    
    int hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  /// Get staff initials for avatar
  static String getStaffInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Generate staff member ID/code
  static String generateStaffCode(String firstName, String lastName, int id) {
    String firstTwo = firstName.length >= 2 ? firstName.substring(0, 2).toUpperCase() : firstName.toUpperCase();
    String lastTwo = lastName.length >= 2 ? lastName.substring(0, 2).toUpperCase() : lastName.toUpperCase();
    String idPart = id.toString().padLeft(3, '0');
    return '$firstTwo$lastTwo$idPart';
  }
}
