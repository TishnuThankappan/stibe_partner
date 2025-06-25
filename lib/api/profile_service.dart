import 'dart:io';
import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/profile_update_model.dart';
import 'package:stibe_partner/models/user_model.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<User> getProfile() async {
    final response = await _apiService.get('/auth/me');
    
    if (response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    throw Exception('Failed to get profile');
  }

  // Update user profile
  Future<User> updateProfile(ProfileUpdateModel profile) async {
    final response = await _apiService.put('/auth/profile', data: profile.toJson());
    
    if (response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    throw Exception('Failed to update profile');
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile) async {
    final response = await _apiService.uploadFile(
      '/auth/profile/image',
      imageFile,
      fieldName: 'profileImage',
    );
    
    if (response['data'] != null && response['data']['imageUrl'] != null) {
      return response['data']['imageUrl'];
    }
    
    throw Exception('Failed to upload profile image');
  }
}
