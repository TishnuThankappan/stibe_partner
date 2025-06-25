import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stibe_partner/constants/app_theme.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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
        // Get token from secure storage
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, refresh or logout
          // Implement token refresh logic here
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
      print('🌐 API POST Request');
      print('🔗 URL: ${_dio.options.baseUrl}$endpoint');
      print('📤 Data: $data');
      
      final response = await _dio.post(
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
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
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
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // For backward compatibility - alias to clearAuthToken
  Future<void> removeAuthToken() async {
    await clearAuthToken();
  }

  // Get stored token
  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
  
  // For backward compatibility - alias to getStoredToken
  Future<String?> getAuthToken() async {
    return await getStoredToken();
  }
  
  // Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: 'user_data', value: json.encode(userData));
  }
  
  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUserData() async {
    final userDataString = await _secureStorage.read(key: 'user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
  
  // Clear stored user data
  Future<void> clearStoredUserData() async {
    await _secureStorage.delete(key: 'user_data');
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
