import 'package:stibe_partner/api/api_service.dart';

class TestService {
  final ApiService _apiService = ApiService();

  // Test health endpoint
  Future<bool> testHealthCheck() async {
    try {
      final response = await _apiService.get('/test/health');
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Test protected endpoint (requires authentication)
  Future<bool> testProtectedEndpoint() async {
    try {
      final response = await _apiService.get('/test/protected');
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Test salon owner endpoint
  Future<bool> testSalonOwnerEndpoint() async {
    try {
      final response = await _apiService.get('/test/salon-owner');
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Test debug claims endpoint
  Future<Map<String, dynamic>?> testDebugClaims() async {
    try {
      final response = await _apiService.get('/test/debug-claims');
      return response['data'];
    } catch (e) {
      return null;
    }
  }

  // Comprehensive API test
  Future<Map<String, dynamic>> runApiTests() async {
    final results = <String, dynamic>{};
    
    // Test basic connectivity
    results['health_check'] = await testHealthCheck();
    
    // Test authentication required endpoints
    results['protected_endpoint'] = await testProtectedEndpoint();
    results['salon_owner_endpoint'] = await testSalonOwnerEndpoint();
    
    // Test debug info
    results['debug_claims'] = await testDebugClaims();
    
    // Test API base URL connectivity
    try {
      await _apiService.get('/test/health');
      results['api_connectivity'] = true;
    } catch (e) {
      results['api_connectivity'] = false;
      results['error'] = e.toString();
    }
    
    return results;
  }
}
