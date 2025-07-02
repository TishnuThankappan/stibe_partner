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
    bool rememberMe = false,
  }) async {
    final Stopwatch loginStopwatch = Stopwatch()..start();
    print('🔐 LOGIN ATTEMPT');
    
    // Only print detailed logs in development mode
    if (AppConfig.isDevelopment) {
      print('📧 Email: $email');
      print('🔑 Remember Me: $rememberMe');
      print('🔗 URL: ${AppConstants.baseUrl}/auth/login');
    }
    
    final loginData = {
      'email': email,
      'password': password,
    };
    
    print('⏱️ Starting API request at ${loginStopwatch.elapsedMilliseconds}ms');
    final response = await _apiService.post('/auth/login', data: loginData);
    print('⏱️ API request completed at ${loginStopwatch.elapsedMilliseconds}ms');
    
    // Start processing response as early as possible
    if (response['data'] != null) {
      final data = response['data'];
      final token = data['token'];
      final userData = data['user'] ?? data;
      
      // Create a User object early to avoid delays - this is synchronous and fast
      final user = User.fromJson(userData);
      print('⏱️ User object created at ${loginStopwatch.elapsedMilliseconds}ms');
      
      // Launch storage operations in parallel and don't await them
      // This allows us to return the user object immediately
      _startBackgroundStorageOperations(token, userData, email, password, rememberMe);
      
      print('⏱️ Login completed at ${loginStopwatch.elapsedMilliseconds}ms');
      return user;
    }

    throw Exception('Login failed: Invalid response from server');
  }
  
  // Handle storage operations in the background
  void _startBackgroundStorageOperations(
    String? token, 
    Map<String, dynamic> userData, 
    String email, 
    String password, 
    bool rememberMe
  ) {
    // Run storage operations in a fire-and-forget manner
    Future.wait([
      // Only store token if it exists
      if (token != null) _apiService.setAuthToken(token),
      
      // Store user data
      _apiService.storeUserData(userData),
      
      // Handle remember me
      if (rememberMe) 
        _apiService.storeCredentials(email, password)
      else 
        _apiService.clearStoredCredentials()
    ]).then((_) {
      if (AppConfig.isDevelopment) {
        print('✅ Background storage operations completed');
      }
    }).catchError((error) {
      print('❌ Error during background storage: $error');
      // We don't rethrow here since this is happening in the background
    });
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
    final Stopwatch profileStopwatch = Stopwatch()..start();
    print('⏱️ getProfile started');
    
    User? user;
    
    // Try getting user from API and local storage in parallel
    try {
      // First try to get user data from storage (faster)
      final storedUserDataFuture = _apiService.getStoredUserData();
      
      // Simultaneously request fresh data from API
      final apiFuture = _apiService.get('/auth/profile');
      
      // Wait for both operations with a timeout
      final results = await Future.wait([
        storedUserDataFuture.timeout(const Duration(seconds: 2), 
          onTimeout: () => null),
        apiFuture.timeout(const Duration(seconds: 5), 
          onTimeout: () => {'success': false, 'message': 'API timeout'})
      ]);
      
      final storedUserData = results[0];
      final apiResponse = results[1];
      
      // First try to use API response if available
      if (apiResponse != null && apiResponse['data'] != null) {
        print('⏱️ Using API profile data at ${profileStopwatch.elapsedMilliseconds}ms');
        user = User.fromJson(apiResponse['data']);
        
        // Store updated user data in background
        _apiService.storeUserData(apiResponse['data']);
        
        print('⏱️ API profile data processed at ${profileStopwatch.elapsedMilliseconds}ms');
        return user;
      }
      
      // Fall back to stored data if API failed or timed out
      if (storedUserData != null) {
        print('⏱️ Using cached profile data at ${profileStopwatch.elapsedMilliseconds}ms');
        user = User.fromJson(storedUserData);
        return user;
      }
    } catch (e) {
      print('Error in getProfile: $e');
      
      // If we have a partially populated user from one of the sources, use it
      if (user != null) {
        print('⏱️ Returning partial user data at ${profileStopwatch.elapsedMilliseconds}ms');
        return user;
      }
    }
    
    // If we get here, both methods failed
    throw Exception('Failed to get user profile data');
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
  Future<void> logout({bool preserveRememberMe = true}) async {
    print('🚪 Logout process initiated');
    print('🔍 DEBUG AuthService.logout - preserveRememberMe: $preserveRememberMe');
    
    try {
      // First check if Remember Me is actually enabled before we try to preserve it
      final rememberMeStatus = await _apiService.getStoredCredentials();
      final rememberMeEnabled = rememberMeStatus != null;
      
      print('🔍 DEBUG Actual Remember Me status before logout: $rememberMeEnabled');
      
      // Only preserve if both the parameter is true AND Remember Me is actually enabled
      final shouldPreserveCredentials = preserveRememberMe && rememberMeEnabled;
      
      // Skip server-side logout since the endpoint doesn't exist in the API
      // Just handle the client-side logout process
      
      // To avoid any dashboard visibility after logout, clear everything in this order:
      
      // 1. First clear local token storage - this will prevent any API calls from working
      await _apiService.clearAuthToken();
      print('✅ Auth token cleared');
      
      // 2. Clear stored user data
      await _apiService.clearStoredUserData();
      print('✅ User data cleared');
      
      // 3. Handle stored credentials from "Remember Me" based on the preserveRememberMe flag
      if (shouldPreserveCredentials) {
        print('🔒 Remember Me credentials preserved for next login');
      } else {
        await _apiService.clearStoredCredentials(preserveForRememberMe: false);
        print('✅ Stored credentials cleared - preserveRememberMe=$preserveRememberMe, rememberMeEnabled=$rememberMeEnabled');
      }
      
      // Clear any other local storage related to user session if needed
      print('🚪 User successfully logged out - all data cleared');
    } catch (e) {
      print('❌ Error during logout process: $e');
      rethrow;
    }
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

  // Get stored credentials (for Remember Me)
  Future<Map<String, String>?> getStoredCredentials() async {
    return await _apiService.getStoredCredentials();
  }
  
  // Clear stored credentials
  Future<void> clearStoredCredentials({bool preserveForRememberMe = false}) async {
    await _apiService.clearStoredCredentials(preserveForRememberMe: preserveForRememberMe);
  }
}
