import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register a new salon owner
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    final response = await _apiService.post('/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    });

    // Save token if available
    if (response['token'] != null) {
      await _apiService.setAuthToken(response['token']);
    }

    return User.fromJson(response['user']);
  }

  // Login to partner account
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/login', data: {
      'email': email,
      'password': password,
    });

    // Save token
    await _apiService.setAuthToken(response['token']);

    return User.fromJson(response['user']);
  }

  // Verify email
  Future<bool> verifyEmail({required String code}) async {
    final response = await _apiService.post('/verify-email', data: {
      'code': code,
    });

    return response['verified'] ?? false;
  }

  // Verify phone
  Future<bool> verifyPhone({required String code}) async {
    final response = await _apiService.post('/verify-phone', data: {
      'code': code,
    });

    return response['verified'] ?? false;
  }

  // Get user profile
  Future<User> getProfile() async {
    final response = await _apiService.get('/profile');
    return User.fromJson(response['user']);
  }

  // Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    final data = {};
    
    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (profileImage != null) data['profileImage'] = profileImage;

    final response = await _apiService.put('/profile', data: data);
    return User.fromJson(response['user']);
  }

  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    final response = await _apiService.post('/forgot-password', data: {
      'email': email,
    });

    return response['sent'] ?? false;
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiService.post('/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });

    return response['reset'] ?? false;
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.put('/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    return response['changed'] ?? false;
  }

  // Logout
  Future<void> logout() async {
    await _apiService.post('/logout');
    await _apiService.removeAuthToken();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getAuthToken();
    return token != null;
  }

  // Submit business information
  Future<Business> submitBusinessInfo({
    required String name,
    required String address,
    String? description,
    required Location location,
    required List<String> serviceCategories,
  }) async {
    final response = await _apiService.post('/business', data: {
      'name': name,
      'address': address,
      'description': description,
      'location': location.toJson(),
      'serviceCategories': serviceCategories,
    });

    return Business.fromJson(response['business']);
  }

  // Upload business documents
  Future<bool> uploadBusinessDocuments({
    required List<String> documentUrls,
    required List<String> documentTypes,
  }) async {
    final response = await _apiService.post('/business/documents', data: {
      'documentUrls': documentUrls,
      'documentTypes': documentTypes,
    });

    return response['uploaded'] ?? false;
  }

  // Update business hours
  Future<List<OpeningHours>> updateBusinessHours({
    required List<OpeningHours> hours,
  }) async {
    final response = await _apiService.put('/business/hours', data: {
      'hours': hours.map((hour) => hour.toJson()).toList(),
    });

    return (response['hours'] as List)
        .map((hour) => OpeningHours.fromJson(hour))
        .toList();
  }
}
