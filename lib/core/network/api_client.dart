// lib/core/network/api_client.dart - COMPLETE FIXED VERSION WITH PAGINATED RESPONSE
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../utils/app_constants.dart';

// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return PaginatedResponse<T>(
      data: dataList.map((item) => fromJson(item as Map<String, dynamic>)).toList(),
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 10,
      total: pagination['total'] ?? 0,
      totalPages: pagination['totalPages'] ?? 1,
      hasNextPage: pagination['hasNextPage'] ?? false,
      hasPrevPage: pagination['hasPrevPage'] ?? false,
    );
  }
}

// Response wrapper for API responses
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'] as Map<String, dynamic>)
          : json['data'] as T?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class ApiClient {
  static const String baseUrl = AppConstants.baseUrl;
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Add auth token if available
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            print('*** Request ***');
            print('uri: ${options.uri}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
            print('');
          }
        } catch (e) {
          print('Error in request interceptor: $e');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('*** Response ***');
          print('uri: ${response.requestOptions.uri}');
          
          // Log response data safely
          if (response.data != null) {
            final responseStr = response.data.toString();
            if (responseStr.length > 1000) {
              print('Data: ${responseStr.substring(0, 1000)}...[truncated]');
            } else {
              print('Data: $responseStr');
            }
          }
          print('');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('Message: ${error.message}');
          if (error.response?.data != null) {
            print('Error Data: ${error.response?.data}');
          }
        }

        // Handle authentication errors
        if (error.response?.statusCode == 401) {
          print('401 Unauthorized - attempting token refresh...');
          
          // Try to refresh token
          try {
            final refreshed = await _handleTokenRefresh();
            if (refreshed) {
              // Retry original request with new token
              final newToken = await _secureStorage.getAccessToken();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            }
          } catch (refreshError) {
            print('Token refresh failed: $refreshError');
            await _secureStorage.clearTokens();
          }
        }

        handler.next(error);
      },
    ));

    // Add logging interceptor in debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Disable to prevent sensitive data logging
        responseBody: false, // Disable to prevent large response logging
        logPrint: (obj) => print(obj),
      ));
    }
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return false;
      }

      // Create a new Dio instance for refresh to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> tokenData;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            tokenData = responseData['data'] as Map<String, dynamic>;
          } else {
            tokenData = responseData;
          }
        } else {
          print('Invalid refresh response format');
          return false;
        }

        final newAccessToken = tokenData['accessToken'] ?? tokenData['access_token'];
        final newRefreshToken = tokenData['refreshToken'] ?? tokenData['refresh_token'];

        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.saveTokens(newAccessToken, newRefreshToken);
          print('Token refresh successful');
          return true;
        }
      }

      print('Token refresh failed - invalid response data');
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  // GET request with enhanced error handling
  Future<Response> get(String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // POST request with enhanced error handling
  Future<Response> post(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // PUT request with enhanced error handling
  Future<Response> put(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // DELETE request with enhanced error handling
  Future<Response> delete(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Enhanced error handling
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      
      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server error occurred';
        
        // Extract error message from response
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   responseData['detail'] ?? 
                   'Server error occurred';
        } else if (responseData is String) {
          message = responseData;
        }
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized access. Please log in again.');
          case 403:
            return Exception('Access forbidden. You don\'t have permission.');
          case 404:
            return Exception('Route not found (Status: $statusCode)');
          case 422:
            return Exception('Validation error: $message');
          case 500:
            return Exception('Internal server error. Please try again later.');
          case 503:
            return Exception('Service unavailable. Please try again later.');
          default:
            return Exception('$message (Status: $statusCode)');
        }
      
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return Exception('No internet connection. Please check your network.');
        }
        return Exception('Network error: ${e.message}');
      
      default:
        return Exception('Unexpected error occurred: ${e.message}');
    }
  }

  // Health check method
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('/health', 
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Test basic connectivity without auth
  Future<bool> testBasicConnection() async {
    try {
      final testDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      final response = await testDio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Basic connection test failed: $e');
      return false;
    }
  }

  void dispose() {
    _dio.close();
  }
}

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  return ApiClient(secureStorage);
});