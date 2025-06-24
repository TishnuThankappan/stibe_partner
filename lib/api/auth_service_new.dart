import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/user_model.dart';

class AuthService {
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

    // Save token if available (from .NET API response structure)
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      return User.fromJson(data['user'] ?? data);
    }

    throw Exception('Registration failed');
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

    // Save token (from .NET API response structure)
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      return User.fromJson(data['user'] ?? data);
    }

    throw Exception('Login failed');
  }

  // Verify email
  Future<bool> verifyEmail({required String email, required String token}) async {
    try {
      final response = await _apiService.get('/auth/verify-email?email=$email&token=$token');
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    final response = await _apiService.get('/auth/me');
    
    if (response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    throw Exception('Failed to get profile');
  }

  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.removeAuthToken();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user ID from token
  Future<String?> getCurrentUserId() async {
    try {
      final user = await getProfile();
      return user.id.toString();
    } catch (e) {
      return null;
    }
  }
}
