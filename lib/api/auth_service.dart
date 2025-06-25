import 'dart:io';
import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/user_model.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/utils/image_utils.dart';

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
  }  // Login to partner account
  Future<User> login({
    required String email,
    required String password,
  }) async {
    print('🔐 LOGIN ATTEMPT');
    print('📧 Email: $email');
    print('🔗 URL: ${AppConstants.baseUrl}/auth/login');
    
    final loginData = {
      'email': email,
      'password': password,
    };
    print('📤 Request Data: $loginData');
    
    final response = await _apiService.post('/auth/login', data: loginData);
    
    print('📥 Response: $response');

    // Save token (from .NET API response structure)
    if (response['data'] != null) {
      final data = response['data'];
      print('✅ Login successful - Token received: ${data['token'] != null}');
      if (data['token'] != null) {
        await _apiService.setAuthToken(data['token']);
      }
      
      // Store user data for later use
      final userData = data['user'] ?? data;
      await _apiService.storeUserData(userData);
      print('💾 User data stored: $userData');
      
      return User.fromJson(userData);
    }

    print('❌ Login failed - No data in response');
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
    try {
      // First try using the /auth/profile endpoint
      final response = await _apiService.get('/auth/profile');
      
      print('📋 Get Profile Response:');
      print('  - Status: ${response['success']}');
      print('  - Message: ${response['message']}');
      
      if (response['data'] != null) {
        print('  - User data: ${response['data']}');
        print('  - Profile image from API: ${response['data']['profileImage'] ?? response['data']['profilePictureUrl']}');
        
        final user = User.fromJson(response['data']);
        print('  - Processed profile image: ${user.profileImage}');
        print('  - Formatted profile image: ${user.formattedProfileImage}');
        
        return user;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      // Fall back to using stored user data from login if /auth/profile endpoint fails
    }
    
    // As a fallback, use the stored user data from shared preferences
    try {
      final userData = await _apiService.getStoredUserData();
      if (userData != null) {
        print('📋 Using stored user data: $userData');
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Error fetching stored user data: $e');
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
    await _apiService.clearAuthToken();
    await _apiService.clearStoredUserData();
    print('🚪 User logged out - cleared token and user data');
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

  // Check if email is verified
  Future<bool> checkEmailVerification(String email) async {
    try {
      final response = await _apiService.get('/auth/check-verification?email=${Uri.encodeComponent(email)}');
      return response['data']?['isEmailVerified'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    try {
      final response = await _apiService.post('/auth/resend-verification', data: {
        'email': email,
      });
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    final response = await _apiService.put('/auth/profile', data: {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profileImage, // Use the correct field name for backend
    });
    
    if (response['data'] != null) {
      final userData = response['data'];
      
      // Store the updated user data
      await _apiService.storeUserData(userData);
      print('💾 Updated user data stored: $userData');
      
      return User.fromJson(userData);
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
    
    print('📸 Upload Profile Image Response: $response');
    
    if (response['data'] != null && response['data']['imageUrl'] != null) {
      final imageUrl = response['data']['imageUrl'];
      print('📸 Image URL: $imageUrl');
      return imageUrl;
    }
    
    throw Exception('Failed to upload profile image');
  }
}
