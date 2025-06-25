import 'package:stibe_partner/api/api_service.dart';

class DotNetStaffService {
  final ApiService _apiService = ApiService();

  // Add staff member to salon
  Future<Map<String, dynamic>> addStaffMember({
    required int salonId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String role,
    String? title,
    String? bio,
    String? profilePictureUrl,
    List<int>? serviceIds,
  }) async {
    final response = await _apiService.post('/staff', data: {
      'salonId': salonId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'title': title,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
      'serviceIds': serviceIds,
    });

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to add staff member');
  }

  // Get staff by ID
  Future<Map<String, dynamic>> getStaffMember(int staffId) async {
    final response = await _apiService.get('/staff/$staffId');

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to get staff member');
  }

  // Get all staff for a salon
  Future<List<Map<String, dynamic>>> getSalonStaff(int salonId) async {
    final response = await _apiService.get('/staff/salon/$salonId');

    if (response['successful'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to get salon staff');
  }

  // Update staff member
  Future<Map<String, dynamic>> updateStaffMember({
    required int staffId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? role,
    String? title,
    String? bio,
    String? profilePictureUrl,
    List<int>? serviceIds,
  }) async {
    final Map<String, dynamic> data = {};
    
    // Only include fields that are not null
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (role != null) data['role'] = role;
    if (title != null) data['title'] = title;
    if (bio != null) data['bio'] = bio;
    if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
    if (serviceIds != null) data['serviceIds'] = serviceIds;

    final response = await _apiService.put('/staff/$staffId', data: data);

    if (response['successful'] == true && response['data'] != null) {
      return response['data'];
    }

    throw Exception(response['message'] ?? 'Failed to update staff member');
  }

  // Delete staff member
  Future<bool> deleteStaffMember(int staffId) async {
    final response = await _apiService.delete('/staff/$staffId');
    return response['successful'] == true;
  }

  // Get staff schedule
  Future<List<Map<String, dynamic>>> getStaffSchedule(int staffId) async {
    final response = await _apiService.get('/staff/$staffId/schedule');

    if (response['successful'] == true && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to get staff schedule');
  }

  // Update staff schedule
  Future<bool> updateStaffSchedule({
    required int staffId,
    required List<Map<String, dynamic>> schedule,
  }) async {
    final response = await _apiService.put('/staff/$staffId/schedule', data: {
      'schedule': schedule,
    });

    return response['successful'] == true;
  }
}
