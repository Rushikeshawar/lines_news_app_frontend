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
      final response = await _apiClient.post(
        '/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data['data']);
      
      // Save tokens
      await _secureStorage.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      
      // Save user data
      await _secureStorage.saveUserData(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: RegisterRequest(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        ).toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data['data']);
      
      // Save tokens
      await _secureStorage.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      
      // Save user data
      await _secureStorage.saveUserData(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // Try to get user from cache first
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }

      // If not in cache, fetch from server
      final response = await _apiClient.get('/auth/me');
      final user = User.fromJson(response.data['data']['user']);
      
      // Cache user data
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (e) {
      // Continue with logout even if server request fails
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.post('/auth/logout-all');
    } catch (e) {
      // Continue with logout even if server request fails
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
        data: UpdateProfileRequest(
          fullName: fullName,
          avatar: avatar,
          preferences: preferences,
        ).toJson(),
      );

      final user = User.fromJson(response.data['data']);
      
      // Update cached user data
      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        '/auth/change-password',
        data: ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ).toJson(),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<RefreshTokenResponse> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data['data']);
      
      // Save new tokens
      await _secureStorage.saveTokens(
        refreshResponse.accessToken,
        refreshResponse.refreshToken,
      );

      return refreshResponse;
    } catch (e) {
      await _secureStorage.clearTokens();
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<UserDashboard> getUserDashboard({String timeframe = '30d'}) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/user',
        queryParameters: {'timeframe': timeframe},
      );

      return UserDashboard.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
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

      final List<dynamic> data = response.data['data'];
      return data.map((item) => ReadingHistoryItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load reading history: $e');
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _apiClient.get(
        '/auth/check-email',
        queryParameters: {'email': email},
      );
      return response.data['data']['available'] ?? false;
    } catch (e) {
      return false;
    }
  }
}