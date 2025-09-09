// lib/features/auth/repositories/auth_repository.dart - FIXED VERSION
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';
import '../../articles/models/article_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Login response received: ${response.statusCode}');
      
      // Handle different response structures
      final responseData = response.data;
      Map<String, dynamic> authData;
      
      if (responseData is Map<String, dynamic>) {
        // Check if data is nested under 'data' key
        if (responseData.containsKey('data')) {
          authData = responseData['data'] as Map<String, dynamic>;
        } else {
          authData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(authData);
      
      // Save tokens with error handling
      try {
        await _secureStorage.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        print('✅ Tokens saved successfully');
      } catch (e) {
        print('⚠️ Error saving tokens: $e');
        // Continue anyway - tokens might still work
      }
      
      // Save user data with error handling
      try {
        await _secureStorage.saveUserData(jsonEncode(authResponse.user.toJson()));
        print('✅ User data saved successfully');
      } catch (e) {
        print('⚠️ Error saving user data: $e');
        // Continue anyway
      }

      return authResponse;
    } catch (e) {
      print('❌ Login failed: $e');
      throw Exception('Login failed: ${_extractErrorMessage(e)}');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      print('📝 Attempting registration for: $email');
      
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role.name.toUpperCase(),
        },
      );

      print('✅ Registration response received: ${response.statusCode}');
      
      // Handle different response structures
      final responseData = response.data;
      Map<String, dynamic> authData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          authData = responseData['data'] as Map<String, dynamic>;
        } else {
          authData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(authData);
      
      // Save tokens
      await _secureStorage.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      
      // Save user data
      await _secureStorage.saveUserData(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } catch (e) {
      print('❌ Registration failed: $e');
      throw Exception('Registration failed: ${_extractErrorMessage(e)}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // First try to get user from cache
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        try {
          final userJson = jsonDecode(userData);
          return User.fromJson(userJson);
        } catch (e) {
          print('⚠️ Error parsing cached user data: $e');
          // Continue to fetch from server
        }
      }

      // Check if we have a valid token
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('⚠️ No access token found');
        return null;
      }

      // Fetch from server
      final response = await _apiClient.get('/auth/me');
      
      final responseData = response.data;
      Map<String, dynamic> userData_server;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is Map<String, dynamic> && data.containsKey('user')) {
            userData_server = data['user'] as Map<String, dynamic>;
          } else {
            userData_server = data as Map<String, dynamic>;
          }
        } else if (responseData.containsKey('user')) {
          userData_server = responseData['user'] as Map<String, dynamic>;
        } else {
          userData_server = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }
      
      final user = User.fromJson(userData_server);
      
      // Cache the user data
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      print('⚠️ Error getting current user: $e');
      
      // If server request fails, clear tokens and return null
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        await _secureStorage.clearTokens();
      }
      
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Try to notify server about logout
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _apiClient.post(
            '/auth/logout',
            data: {'refreshToken': refreshToken},
          );
          print('✅ Server logout successful');
        } catch (e) {
          print('⚠️ Server logout failed: $e');
          // Continue with local logout anyway
        }
      }
    } catch (e) {
      print('⚠️ Logout error: $e');
    } finally {
      // Always clear local storage
      await _secureStorage.clearTokens();
      print('✅ Local tokens cleared');
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.post('/auth/logout-all');
      print('✅ Logout all devices successful');
    } catch (e) {
      print('⚠️ Logout all devices failed: $e');
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  Future<User> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _apiClient.put(
        '/users/profile',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (avatar != null) 'avatar': avatar,
          if (preferences != null) 'preferences': preferences,
        },
      );

      final responseData = response.data;
      Map<String, dynamic> userData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          userData = responseData['data'] as Map<String, dynamic>;
        } else {
          userData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      final user = User.fromJson(userData);
      
      // Update cached user data
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      throw Exception('Failed to update profile: ${_extractErrorMessage(e)}');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to change password: ${_extractErrorMessage(e)}');
    }
  }

  Future<RefreshTokenResponse> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final responseData = response.data;
      Map<String, dynamic> tokenData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          tokenData = responseData['data'] as Map<String, dynamic>;
        } else {
          tokenData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      final refreshResponse = RefreshTokenResponse.fromJson(tokenData);
      
      // Save new tokens
      await _secureStorage.saveTokens(
        refreshResponse.accessToken,
        refreshResponse.refreshToken,
      );

      return refreshResponse;
    } catch (e) {
      await _secureStorage.clearTokens();
      throw Exception('Failed to refresh token: ${_extractErrorMessage(e)}');
    }
  }

  // Test login with demo credentials
  Future<AuthResponse> demoLogin() async {
    return await login('demo@example.com', 'demo123');
  }

  // Helper method to extract meaningful error messages
  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    // Extract message from common error formats
    if (errorStr.contains('message:')) {
      final start = errorStr.indexOf('message:') + 8;
      final end = errorStr.indexOf(',', start);
      if (end > start) {
        return errorStr.substring(start, end).trim();
      }
    }
    
    if (errorStr.contains('Exception:')) {
      return errorStr.substring(errorStr.indexOf('Exception:') + 10).trim();
    }
    
    return errorStr;
  }

  // Utility methods for debugging
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String?>> getStoredTokens() async {
    return {
      'accessToken': await _secureStorage.getAccessToken(),
      'refreshToken': await _secureStorage.getRefreshToken(),
    };
  }

  // Additional methods for dashboard and history (implementing interface)
  Future<UserDashboard> getUserDashboard({String timeframe = '30d'}) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/user',
        queryParameters: {'timeframe': timeframe},
      );

      final responseData = response.data;
      Map<String, dynamic> dashboardData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          dashboardData = responseData['data'] as Map<String, dynamic>;
        } else {
          dashboardData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return UserDashboard.fromJson(dashboardData);
    } catch (e) {
      throw Exception('Failed to load dashboard: ${_extractErrorMessage(e)}');
    }
  }

  Future<List<ReadingHistoryItem>> getReadingHistory({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? order,
  }) async {
    try {
      final response = await _apiClient.get(
        '/users/reading-history',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (sortBy != null) 'sortBy': sortBy,
          if (order != null) 'order': order,
        },
      );

      final responseData = response.data;
      List<dynamic> historyData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            historyData = data;
          } else if (data is Map && data.containsKey('items')) {
            historyData = data['items'] as List;
          } else {
            historyData = [];
          }
        } else {
          historyData = [];
        }
      } else if (responseData is List) {
        historyData = responseData;
      } else {
        historyData = [];
      }

      return historyData.map((item) => ReadingHistoryItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load reading history: ${_extractErrorMessage(e)}');
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _apiClient.get(
        '/auth/check-email',
        queryParameters: {'email': email},
      );
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data']['available'] ?? false;
        }
        return responseData['available'] ?? false;
      }
      
      return false;
    } catch (e) {
      print('Email availability check failed: $e');
      return false;
    }
  }
}