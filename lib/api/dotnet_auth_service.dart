import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/user_model.dart';

class DotNetAuthService {
  final ApiService _apiService = ApiService();

  // Register a new salon owner
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String role = 'SalonOwner',
  }) async {
    final response = await _apiService.post('/auth/register', data: {
      'email': email,
      'password': password,
      'confirmPassword': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
    });

    if (response['successful'] == true && response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      return User.fromJson(data['user'] ?? data);
    }

    throw Exception(response['message'] ?? 'Registration failed');
  }

  // Login to partner account
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response['successful'] == true && response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      return User.fromJson(data['user'] ?? data);
    }

    throw Exception(response['message'] ?? 'Login failed');
  }

  // Google OAuth functionality has been removed

  // Verify email
  Future<bool> verifyEmail({required String email, required String token}) async {
    try {
      final response = await _apiService.get('/auth/verify-email?email=$email&token=$token');
      return response['successful'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    final response = await _apiService.get('/auth/me');
    
    if (response['successful'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    throw Exception(response['message'] ?? 'Failed to get profile');
  }

  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response['successful'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return response['successful'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return response['successful'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.clearAuthToken();
  }
}
