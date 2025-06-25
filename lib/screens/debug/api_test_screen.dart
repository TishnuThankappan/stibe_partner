import 'package:flutter/material.dart';
import 'package:stibe_partner/api/test_service.dart';
import 'package:stibe_partner/api/auth_service.dart';
import 'package:stibe_partner/api/dotnet_auth_service.dart';
import 'package:stibe_partner/api/api_service.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final TestService _testService = TestService();
  final AuthService _authService = AuthService();
  final DotNetAuthService _dotnetAuthService = DotNetAuthService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;
  String? _error;
  String _dotnetApiResult = 'No .NET API tests run yet';
  bool _isDotnetLoading = false;

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _testResults = null;
    });

    try {
      final results = await _testService.runApiTests();
      setState(() {
        _testResults = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authService.register(
        email: "test@example.com",
        password: "password123",
        firstName: "Test",
        lastName: "User",
        phoneNumber: "+1234567890",
        role: "SalonOwner",
      );
      
      setState(() {
        _testResults = {
          'registration': 'SUCCESS',
          'user_id': user.id,
          'user_name': user.fullName,
          'user_email': user.email,
        };
      });
    } catch (e) {
      setState(() {
        _error = 'Registration test failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDotnetApiConnection() async {
    setState(() {
      _isDotnetLoading = true;
      _dotnetApiResult = 'Testing .NET API connection...';
    });

    try {
      // Use the ApiService directly to test a simple endpoint
      final ApiService apiService = ApiService();
      final response = await apiService.get('/test/health');
      
      setState(() {
        _isDotnetLoading = false;
        _dotnetApiResult = 'API Connection Success!\n\n${response.toString().substring(0, response.toString().length > 300 ? 300 : response.toString().length)}...';
      });
    } catch (e) {
      setState(() {
        _isDotnetLoading = false;
        _dotnetApiResult = 'API Connection Failed:\n\n${e.toString()}';
      });
    }
  }

  Future<void> _testDotnetLogin() async {
    setState(() {
      _isDotnetLoading = true;
      _dotnetApiResult = 'Testing .NET API login...';
    });

    try {
      // Using default test credentials
      final user = await _dotnetAuthService.login(
        email: 'admin@stibe.com',
        password: 'Test@123',
      );
      
      setState(() {
        _isDotnetLoading = false;
        _dotnetApiResult = 'Login Success!\n\nUser: ${user.toString()}';
      });
    } catch (e) {
      setState(() {
        _isDotnetLoading = false;
        _dotnetApiResult = 'Login Failed:\n\n${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test your .NET API connection',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _runTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test API Connectivity'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test User Registration'),
            ),
            
            const SizedBox(height: 20),
            
            // Add divider and section for .NET API tests
            const Divider(thickness: 2),
            
            Text(
              'Test .NET API Connection',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Base URL: ${AppConstants.baseUrl}',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isDotnetLoading ? null : _testDotnetApiConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isDotnetLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test .NET API Connection'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isDotnetLoading ? null : _testDotnetLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Test .NET Login'),
            ),
            
            const SizedBox(height: 20),
            
            if (_dotnetApiResult.isNotEmpty && _dotnetApiResult != 'No .NET API tests run yet') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _dotnetApiResult.contains('Failed') 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _dotnetApiResult.contains('Failed')
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dotnetApiResult.contains('Failed') ? 'Error:' : 'Success:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _dotnetApiResult.contains('Failed')
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dotnetApiResult,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            
            if (_testResults != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._testResults!.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Make sure your .NET API is running at https://localhost:7090',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2. Click "Test API Connectivity" to check connection',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '3. Click "Test User Registration" to test auth endpoints',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '4. Check console for detailed error messages',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
