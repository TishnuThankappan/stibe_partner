import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // In-memory cache for better performance
  Map<String, dynamic>? _userDataCache;
  String? _authTokenCache;
  Map<String, String>? _credentialsCache;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),  // Reduced from 30 seconds
        receiveTimeout: const Duration(seconds: 10),  // Reduced from 30 seconds
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // For development: Skip certificate verification for localhost
    if (AppConfig.isDevelopment) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final Stopwatch requestStopwatch = Stopwatch()..start();
        
        // Get token from cache first, then fall back to secure storage
        String? token = _authTokenCache;
        if (token == null) {
          token = await _secureStorage.read(key: 'auth_token');
          // Update cache if token was found
          if (token != null) {
            _authTokenCache = token;
          }
        }
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add request ID and timing information
        options.extra['requestId'] = DateTime.now().millisecondsSinceEpoch.toString();
        options.extra['requestStartTime'] = requestStopwatch.elapsedMilliseconds;
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Calculate response time if request start time is available
        if (response.requestOptions.extra.containsKey('requestStartTime')) {
          final startTime = response.requestOptions.extra['requestStartTime'] as int;
          final endTime = DateTime.now().millisecondsSinceEpoch;
          final duration = endTime - startTime;
          
          if (AppConfig.isDevelopment) {
            print('⏱️ Request completed in ${duration}ms: ${response.requestOptions.path}');
          }
        }
        
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid, log the error
          print('🚫 Authentication error: Token expired or invalid');
          
          // Clear both cache and storage
          _authTokenCache = null;
          try {
            await clearAuthToken();
            print('✅ Auth token cleared after 401 error');
          } catch (clearError) {
            print('❌ Error clearing token after 401: $clearError');
          }
        }
        return handler.next(e);
      },
    ));
  }
  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      print('🌐 API GET Request');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      if (queryParams != null) {
        print('📤 Query Params: $queryParams');
      }
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      print('❌ API Error:');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('💥 Error Type: ${e.type}');
      print('💥 Error Message: ${e.message}');
      print('💥 Response: ${e.response?.data}');
      print('💥 Status Code: ${e.response?.statusCode}');
      
      _handleError(e);
      rethrow;
    }
  }
  // Generic POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      // Only print detailed logs in development mode
      if (AppConfig.isDevelopment) {
        print('🌐 API POST Request');
        print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
        
        // Don't log sensitive data like passwords in full
        final sanitizedData = data is Map ? _sanitizeData(data) : data;
        print('📤 Data: $sanitizedData');
      }
      
      final Stopwatch stopwatch = Stopwatch()..start();
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      stopwatch.stop();
      
      if (AppConfig.isDevelopment) {
        print('⏱️ Request took: ${stopwatch.elapsedMilliseconds}ms');
        print('📥 Response Status: ${response.statusCode}');
      }
      
      return response.data;
    } on DioException catch (e) {
      if (AppConfig.isDevelopment) {
        print('❌ API Error:');
        print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
        print('💥 Error Type: ${e.type}');
        print('💥 Error Message: ${e.message}');
        print('💥 Response: ${e.response?.data}');
        print('💥 Status Code: ${e.response?.statusCode}');
      }
      
      _handleError(e);
      rethrow;
    }
  }
  
  // Sanitize sensitive data for logging
  dynamic _sanitizeData(Map data) {
    final sanitized = Map<String, dynamic>.from(data);
    if (sanitized.containsKey('password')) {
      sanitized['password'] = '****';
    }
    if (sanitized.containsKey('currentPassword')) {
      sanitized['currentPassword'] = '****';
    }
    if (sanitized.containsKey('newPassword')) {
      sanitized['newPassword'] = '****';
    }
    if (sanitized.containsKey('confirmPassword')) {
      sanitized['confirmPassword'] = '****';
    }
    return sanitized;
  }

  // Upload file
  Future<dynamic> uploadFile(String endpoint, File file, {String fieldName = 'file'}) async {
    try {
      print('🌐 API FILE Upload Request');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('📁 File: ${file.path}');
      
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
      });
      
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      print('❌ API File Upload Error:');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('💥 Error Type: ${e.type}');
      print('💥 Error Message: ${e.message}');
      print('💥 Response: ${e.response?.data}');
      print('💥 Status Code: ${e.response?.statusCode}');
      
      _handleError(e);
      rethrow;
    }
  }

  // Upload multiple files
  Future<dynamic> uploadFiles(String endpoint, List<File> files, {String fieldName = 'files'}) async {
    try {
      print('🌐 API MULTIPLE FILE Upload Request');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('📁 Files: ${files.length} files');
      
      final formData = FormData();
      
      for (int i = 0; i < files.length; i++) {
        formData.files.add(
          MapEntry(
            fieldName,
            await MultipartFile.fromFile(files[i].path),
          ),
        );
      }
      
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      print('❌ API Multiple File Upload Error:');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('💥 Error Type: ${e.type}');
      print('💥 Error Message: ${e.message}');
      print('💥 Response: ${e.response?.data}');
      print('💥 Status Code: ${e.response?.statusCode}');
      
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      print('🌐 API PUT Request');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('📤 Data: $data');
      
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      print('❌ API Error:');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('💥 Error Type: ${e.type}');
      print('💥 Error Message: ${e.message}');
      print('💥 Response: ${e.response?.data}');
      print('💥 Status Code: ${e.response?.statusCode}');
      
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Error handling
  void _handleError(DioException e) {
    String errorMessage = 'An error occurred';
    
    if (e.response != null) {
      // Server responded with an error
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'];
      } else if (statusCode == 401) {
        errorMessage = 'Unauthorized access';
      } else if (statusCode == 404) {
        errorMessage = 'Resource not found';
      } else if (statusCode == 500) {
        errorMessage = 'Server error';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Server is taking too long to respond';
    } else if (e.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Request timeout';
    } else if (e.type == DioExceptionType.cancel) {
      errorMessage = 'Request canceled';
    } else {
      errorMessage = 'Network error: ${e.message}';
    }
    
    throw Exception(errorMessage);
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    // Update in-memory cache immediately
    _authTokenCache = token;
    
    // Use write without waiting for the result in non-critical paths
    _secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    try {
      // Clear cache immediately
      _authTokenCache = null;
      
      if (AppConfig.isDevelopment) {
        print('🔑 Clearing auth token from secure storage');
      }
      await _secureStorage.delete(key: 'auth_token');
      
      if (AppConfig.isDevelopment) {
        print('✅ Auth token cleared successfully');
      }
    } catch (e) {
      if (AppConfig.isDevelopment) {
        print('❌ Error clearing auth token: $e');
      }
      // Rethrow so callers can handle the error
      rethrow;
    }
  }

  // For backward compatibility - alias to clearAuthToken
  Future<void> removeAuthToken() async {
    await clearAuthToken();
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    // Return from in-memory cache if available
    if (_authTokenCache != null) {
      return _authTokenCache;
    }
    
    // Get from secure storage and update cache
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      _authTokenCache = token;
    }
    
    return token;
  }
  
  // For backward compatibility - alias to getStoredToken
  Future<String?> getAuthToken() async {
    return await getStoredToken();
  }
  
  // Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    // Update in-memory cache immediately
    _userDataCache = userData;
    
    // Store in secure storage
    await _secureStorage.write(key: 'user_data', value: json.encode(userData));
  }
  
  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUserData() async {
    // Return from in-memory cache if available
    if (_userDataCache != null) {
      return _userDataCache;
    }
    
    // Get from secure storage and update cache
    final userDataString = await _secureStorage.read(key: 'user_data');
    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString) as Map<String, dynamic>;
        _userDataCache = userData;
        return userData;
      } catch (e) {
        print('❌ Error parsing stored user data: $e');
        return null;
      }
    }
    return null;
  }
  
  // Clear stored user data
  Future<void> clearStoredUserData() async {
    try {
      // Clear cache immediately
      _userDataCache = null;
      
      print('👤 Clearing user data from secure storage');
      await _secureStorage.delete(key: 'user_data');
      print('✅ User data cleared successfully');
    } catch (e) {
      print('❌ Error clearing user data: $e');
      // Rethrow so callers can handle the error
      rethrow;
    }
  }

  // Store credentials for "Remember Me" functionality
  Future<void> storeCredentials(String email, String password) async {
    try {
      print('🔒 Storing credentials for Remember Me');
      
      // Update in-memory cache
      _credentialsCache = {
        'email': email,
        'password': password
      };
      
      // Store in secure storage
      await Future.wait([
        _secureStorage.write(key: 'remembered_email', value: email),
        _secureStorage.write(key: 'remembered_password', value: password),
        _secureStorage.write(key: 'remember_me_enabled', value: 'true')
      ]);
      
      print('✅ Credentials stored successfully');
    } catch (e) {
      print('❌ Error storing credentials: $e');
      rethrow;
    }
  }
  
  // Get stored credentials
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      // Return from in-memory cache if available
      if (_credentialsCache != null) {
        return _credentialsCache;
      }
      
      final rememberMeEnabled = await _secureStorage.read(key: 'remember_me_enabled');
      
      if (rememberMeEnabled == 'true') {
        // Get credentials in parallel
        final email = await _secureStorage.read(key: 'remembered_email');
        final password = await _secureStorage.read(key: 'remembered_password');
        
        if (email != null && password != null) {
          // Update in-memory cache
          _credentialsCache = {
            'email': email,
            'password': password
          };
          
          print('✅ Retrieved stored credentials');
          return _credentialsCache;
        }
      }
      
      print('🔍 No stored credentials found or remember me not enabled');
      return null;
    } catch (e) {
      print('❌ Error getting stored credentials: $e');
      return null;
    }
  }
  
  // Clear stored credentials
  Future<void> clearStoredCredentials({bool preserveForRememberMe = false}) async {
    try {
      print('🔍 DEBUG clearStoredCredentials - preserveForRememberMe: $preserveForRememberMe');
      
      // Clear in-memory cache
      _credentialsCache = null;
      
      if (preserveForRememberMe) {
        // Check if remember me was enabled
        final rememberMeEnabled = await _secureStorage.read(key: 'remember_me_enabled');
        print('🔍 DEBUG Remember me enabled status: $rememberMeEnabled');
        
        if (rememberMeEnabled == 'true') {
          print('🔒 Preserving stored credentials for Remember Me');
          return; // Skip deleting credentials
        } else {
          print('⚠️ DEBUG Remember Me was not previously enabled, not preserving credentials');
        }
      } else {
        print('⚠️ DEBUG preserveForRememberMe is false, clearing credentials');
      }
      
      print('🔓 Clearing stored credentials');
      await _secureStorage.delete(key: 'remembered_email');
      await _secureStorage.delete(key: 'remembered_password');
      await _secureStorage.delete(key: 'remember_me_enabled');
      print('✅ Stored credentials cleared successfully');
    } catch (e) {
      print('❌ Error clearing credentials: $e');
      rethrow;
    }
  }

  // Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final status = await _secureStorage.read(key: 'remember_me_enabled');
      print('🔍 DEBUG isRememberMeEnabled: $status');
      return status == 'true';
    } catch (e) {
      print('❌ Error checking remember me status: $e');
      return false;
    }
  }

  // Salon Management APIs
  
  // Create salon with JSON data (mobile-friendly)
  Future<Map<String, dynamic>> createSalon({
    required String name,
    required String description,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String phoneNumber,
    required String email,
    required String openingTime,
    required String closingTime,
    required Map<String, Map<String, dynamic>> businessHours,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('🌐 API POST Request');
      print('🔗 URL: ${AppConstants.baseUrl}/api/salon/create-json');
      
      final data = {
        'name': name,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'phoneNumber': phoneNumber,
        'email': email,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'businessHours': businessHours,
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'useCurrentLocation': latitude != null && longitude != null,
      };
      
      print('📤 Request Data: $data');
      
      final response = await _dio.post(
        '/api/salon/create-json',
        data: data,
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          print('✅ Salon created successfully');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create salon');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to create salon');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Failed to create salon: $e');
    }
  }
  
  // Get user's salons
  Future<Map<String, dynamic>> getMySalons() async {
    try {
      print('🌐 API GET Request');
      print('🔗 URL: ${AppConstants.baseUrl}/api/salon');
      
      final response = await _dio.get('/api/salon');
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          print('✅ Salons retrieved successfully');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to retrieve salons');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to retrieve salons');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Failed to retrieve salons: $e');
    }
  }

  // Get salon by ID
  Future<Map<String, dynamic>> getSalon(int salonId) async {
    try {
      print('🌐 API GET Request');
      print('🔗 URL: ${AppConstants.baseUrl}/api/salon/$salonId');
      
      final response = await _dio.get('/api/salon/$salonId');
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          print('✅ Salon retrieved successfully');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to retrieve salon');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to retrieve salon');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Failed to retrieve salon: $e');
    }
  }
}
