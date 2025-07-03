import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stibe_partner/api/auth_service.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/main.dart'; // For AuthenticationWrapper
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
      } else {
        // Check for stored credentials from "Remember Me"
        final storedCredentials = await _authService.getStoredCredentials();
        if (storedCredentials != null) {
          print('🔑 Found stored credentials - attempting auto-login');
          
          // Try to login with stored credentials
          try {
            _user = await _authService.login(
              email: storedCredentials['email']!,
              password: storedCredentials['password']!,
              // Keep remember me enabled
              rememberMe: true, 
            );
            
            _isAuthenticated = true;
            print('✅ Auto-login successful with stored credentials');
          } catch (autoLoginError) {
            print('❌ Auto-login failed: $autoLoginError');
            // Clear invalid credentials
            await _authService.clearStoredCredentials();
            _isAuthenticated = false;
          }
        }
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
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    
    final Stopwatch loginStopwatch = Stopwatch()..start();
    print('� AuthProvider.login started');
    print('�🔍 DEBUG AuthProvider.login - rememberMe: $rememberMe');
    
    try {
      // Preemptively set the user as authenticated to speed up UI transitions
      // We'll revert this if the login fails
      _isAuthenticated = true;
      notifyListeners();
      print('⏱️ Preemptively set authenticated at ${loginStopwatch.elapsedMilliseconds}ms');
      
      // Actually perform the login
      _user = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      print('⏱️ Login completed at ${loginStopwatch.elapsedMilliseconds}ms');
      return true;
    } catch (e) {
      // Revert the authentication status since login failed
      _isAuthenticated = false;
      _setError(e.toString());
      print('❌ Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
      print('⏱️ AuthProvider.login completed in ${loginStopwatch.elapsedMilliseconds}ms');
    }
  }

  // Logout and navigate to login screen
  Future<void> logoutAndNavigate(BuildContext context, {bool preserveRememberMe = true}) async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🔐 Logout initiated');
      print('🔍 DEBUG AuthProvider.logoutAndNavigate - preserveRememberMe: $preserveRememberMe');
      
      await _authService.logout(preserveRememberMe: preserveRememberMe);
      
      // Clear all user-related data
      _user = null;
      _isAuthenticated = false;
      print('✅ User state cleared successfully');
      
      // Show success snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              preserveRememberMe 
                ? 'Successfully logged out (Remember Me preserved)'
                : 'Successfully logged out'
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Use pushAndRemoveUntil to clear all routes and start fresh
      if (context.mounted) {
        print('🧭 Navigating to login screen after logout');
        
        // Make sure authenticated is false BEFORE navigating
        _isAuthenticated = false;
        notifyListeners();
        
        // IMPORTANT: First pop all routes to eliminate the dashboard from appearing
        // Then push a new route with the AuthenticationWrapper
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthenticationWrapper(),
          ),
          // Remove all existing routes
          (route) => false,
        );
      }
    } catch (e) {
      _setError(e.toString());
      print('❌ Error during logout: $e');
      // Even if there's an error with the API call, still clear the local state
      _user = null;
      _isAuthenticated = false;
      
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } finally {
      _setLoading(false);
      notifyListeners();
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
      final previousProfileImage = _user?.profileImage;
      _user = await _authService.getProfile();
      
      // Debug output to trace profile image changes
      print('🔄 Profile refreshed:');
      print('  - Previous profile image: $previousProfileImage');
      print('  - New profile image: ${_user?.profileImage}');
      print('  - Formatted profile image: ${_user?.formattedProfileImage}');
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      print('❌ Error refreshing profile: $e');
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
        email: _user!.email, // Add required email field
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

  // Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    _setLoading(true);
    _clearError();
    
    try {
      final imageUrl = await _authService.uploadProfileImage(imageFile);
      notifyListeners();
      return imageUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get stored credentials for Remember Me
  Future<Map<String, String>?> getStoredCredentials() async {
    return await _authService.getStoredCredentials();
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
