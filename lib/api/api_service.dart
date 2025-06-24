import 'package:dio/dio.dart';
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
      onError: (DioError e, handler) async {
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
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Error handling
  void _handleError(DioError e) {
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
    } else if (e.type == DioErrorType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (e.type == DioErrorType.receiveTimeout) {
      errorMessage = 'Server is taking too long to respond';
    } else if (e.type == DioErrorType.sendTimeout) {
      errorMessage = 'Request timeout';
    } else if (e.type == DioErrorType.cancel) {
      errorMessage = 'Request canceled';
    } else {
      errorMessage = 'Network error: ${e.message}';
    }
    
    throw Exception(errorMessage);
  }

  // Store auth token
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Remove auth token (logout)
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}
