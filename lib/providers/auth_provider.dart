import 'package:flutter/foundation.dart';
import 'package:stibe_partner/api/auth_service.dart';
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
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
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
  
  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.updateProfile(
        fullName: fullName,
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
  
  // Verify email
  Future<bool> verifyEmail({required String code}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.verifyEmail(code: code);
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
  
  // Verify phone
  Future<bool> verifyPhone({required String code}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.verifyPhone(code: code);
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
  
  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      return await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
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
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      return await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Submit business information
  Future<bool> submitBusinessInfo({
    required String name,
    required String address,
    String? description,
    required Location location,
    required List<String> serviceCategories,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final business = await _authService.submitBusinessInfo(
        name: name,
        address: address,
        description: description,
        location: location,
        serviceCategories: serviceCategories,
      );
      
      // Update user with new business info
      if (_user != null) {
        _user = User(
          id: _user!.id,
          email: _user!.email,
          phoneNumber: _user!.phoneNumber,
          fullName: _user!.fullName,
          profileImage: _user!.profileImage,
          role: _user!.role,
          createdAt: _user!.createdAt,
          business: business,
        );
      }
      
      notifyListeners();
      return true;
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
  }    void _clearError() {
    _error = null;
    notifyListeners();
  }
}
