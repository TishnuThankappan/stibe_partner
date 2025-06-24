import 'package:flutter/foundation.dart';
import 'package:stibe_partner/api/auth_service.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  
  // Initialize auth state
  Future<void> initAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
    // Register new salon owner
  Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      
      // Don't set authenticated if email is not verified
      if (_user!.isEmailVerified) {
        _isAuthenticated = true;
        return null; // No email needed, user can proceed
      } else {
        _isAuthenticated = false;
        return email; // Return email for verification screen
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Verify email
  Future<bool> verifyEmail({
    required String email,
    required String token,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.verifyEmail(
        email: email,
        token: token,
      );
      if (result) {
        // Refresh user profile
        _user = await _authService.getProfile();
      }
      
      return result;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Forgot password
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearError();
    
    try {
      return await _authService.forgotPassword(email: email);
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      return await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
    // Get user profile
  Future<void> refreshProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }  // Submit business information using SalonService
  Future<bool> submitBusinessInfo({
    required String name,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    String? description,
    required Location location,
    required List<String> serviceCategories,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {      print('🏢 BUSINESS PROFILE SETUP');
      print('📝 Name: $name');
      print('📍 Address: $address');
      print('🏙️ City: $city');
      print('�️ State: $state');
      print('📮 Zip Code: $zipCode');
      print('�📄 Description: $description');
      print('🌍 Location: ${location.latitude}, ${location.longitude}');
      print('🏷️ Categories: $serviceCategories');
      
      // We need to get user's phone for salon creation
      if (_user == null) {
        _setError('User information not available. Please login again.');
        return false;
      }
      
      final salonService = SalonService();
      
      // Create salon with provided information matching API requirements
      final createRequest = CreateSalonRequest(
        name: name,
        description: description ?? '',
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        phoneNumber: _user!.phoneNumber, // Use user's phone
        openingTime: '09:00:00', // Default opening time in TimeSpan format
        closingTime: '18:00:00', // Default closing time in TimeSpan format
        currentLatitude: location.latitude,
        currentLongitude: location.longitude,
        useCurrentLocation: location.latitude != 0 && location.longitude != 0,
      );
      
      print('📤 Creating salon with data: ${createRequest.toJson()}');
      
      final salon = await salonService.createSalon(createRequest);
      
      print('✅ Salon created successfully: ${salon.name} (ID: ${salon.id})');
      
      // Note: Service categories are not yet supported by the API
      // These would need to be added as a separate endpoint or field
      if (serviceCategories.isNotEmpty) {
        print('⚠️ Service categories not yet supported by API: $serviceCategories');
        print('💡 Consider adding these as services after salon creation');
      }
      
      return true;
    } catch (e) {
      print('❌ Business profile setup failed: $e');
      _setError('Failed to setup business profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
    // Reset password
  Future<bool> resetPassword({
    String? email,
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // The AuthService doesn't have resetPassword method yet
      // This would need to be added to AuthService to match .NET API
      _setError('Password reset not yet implemented in AuthService.');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Check email verification status
  Future<bool> checkEmailVerification(String email) async {
    try {
      return await _authService.checkEmailVerification(email);
    } catch (e) {
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _authService.resendVerificationEmail(email);
      if (!success) {
        _setError('Failed to send verification email');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
