// lib/features/auth/repositories/auth_repository.dart
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  // ==========================================
  // OTP-BASED REGISTRATION
  // ==========================================
  
  // Step 1: Request OTP for registration
  Future<OTPResponse> requestRegistrationOTP({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      print('Requesting registration OTP for: $email');
      
      final response = await _apiClient.post(
        '/auth/register/request-otp',
        data: {
          'email': email,
          'fullName': fullName,
          'password': password,
        },
      );

      print('OTP request response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
      
      final responseData = response.data;
      Map<String, dynamic> otpData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          otpData = responseData['data'] as Map<String, dynamic>;
        } else {
          otpData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return OTPResponse.fromJson(otpData);
    } catch (e) {
      print('Request OTP failed: $e');
      throw _createUserFriendlyException(e);
    }
  }

  // Step 2: Verify OTP and complete registration
  Future<AuthResponse> verifyOTPAndRegister({
    required String email,
    required String otp,
    UserRole role = UserRole.user,
  }) async {
    try {
      print('Verifying OTP for: $email');
      
      final response = await _apiClient.post(
        '/auth/register/verify-otp',
        data: {
          'email': email,
          'otp': otp,
          'role': role.name.toUpperCase(),
        },
      );

      print('OTP verification response: ${response.statusCode}');
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('OTP verification failed: ${response.statusCode}');
      }
      
      return _processAuthResponse(response.data, 'registration');
    } catch (e) {
      print('OTP verification failed: $e');
      
      // Clean up on failure
      try {
        await _secureStorage.clearTokens();
      } catch (cleanupError) {
        print('Error during cleanup: $cleanupError');
      }
      
      throw _createUserFriendlyException(e);
    }
  }

  // Resend OTP
  Future<OTPResponse> resendOTP(String email) async {
    try {
      print('Resending OTP for: $email');
      
      final response = await _apiClient.post(
        '/auth/register/resend-otp',
        data: {'email': email},
      );

      print('Resend OTP response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP: ${response.statusCode}');
      }
      
      final responseData = response.data;
      Map<String, dynamic> otpData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          otpData = responseData['data'] as Map<String, dynamic>;
        } else {
          otpData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return OTPResponse.fromJson(otpData);
    } catch (e) {
      print('Resend OTP failed: $e');
      throw _createUserFriendlyException(e);
    }
  }

  // ==========================================
  // PASSWORD RESET WITH OTP
  // ==========================================
  
  // Request password reset OTP
  Future<OTPResponse> requestPasswordResetOTP(String email) async {
    try {
      print('Requesting password reset OTP for: $email');
      
      final response = await _apiClient.post(
        '/auth/password/request-reset',
        data: {'email': email},
      );

      print('Password reset OTP request response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send password reset OTP: ${response.statusCode}');
      }
      
      final responseData = response.data;
      Map<String, dynamic> otpData;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          otpData = responseData['data'] as Map<String, dynamic>;
        } else {
          otpData = responseData;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return OTPResponse.fromJson(otpData);
    } catch (e) {
      print('Request password reset OTP failed: $e');
      throw _createUserFriendlyException(e);
    }
  }

  // Verify password reset OTP
  Future<void> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      print('Verifying password reset OTP for: $email');
      
      final response = await _apiClient.post(
        '/auth/password/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      print('Password reset OTP verification response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('OTP verification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Password reset OTP verification failed: $e');
      throw _createUserFriendlyException(e);
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      print('Resetting password for: $email');
      
      final response = await _apiClient.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'newPassword': newPassword,
        },
      );

      print('Password reset response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Password reset failed: ${response.statusCode}');
      }
      
      print('Password reset successful');
    } catch (e) {
      print('Password reset failed: $e');
      throw _createUserFriendlyException(e);
    }
  }

  // ==========================================
  // EXISTING AUTH METHODS
  // ==========================================

  // Token validation
  Future<bool> hasValidToken() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      
      print('Token check - Access: ${accessToken?.substring(0, 20) ?? 'null'}..., Refresh: ${refreshToken?.substring(0, 20) ?? 'null'}...');
      
      if (accessToken == null || accessToken.isEmpty) {
        print('No access token found');
        return false;
      }
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token found');
        return false;
      }
      
      // For demo tokens, return true immediately
      if (accessToken.startsWith('demo_access_token_')) {
        print('Demo token detected, returning valid');
        return true;
      }
      
      // Test token validity
      try {
        final response = await _apiClient.get('/auth/me');
        print('Token validation successful: ${response.statusCode}');
        return response.statusCode == 200;
      } catch (e) {
        print('Token validation failed: $e');
        
        if (e.toString().contains('401')) {
          print('Attempting token refresh...');
          try {
            await _refreshToken();
            print('Token refresh successful');
            return true;
          } catch (refreshError) {
            print('Token refresh failed: $refreshError');
            await _secureStorage.clearTokens();
            return false;
          }
        }
        return false;
      }
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Create demo session
  Future<AuthResponse> createDemoSession() async {
    print('Creating demo session directly...');
    
    try {
      await _secureStorage.clearTokens();
      
      const mockAccessToken = 'demo_access_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo';
      const mockRefreshToken = 'demo_refresh_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo';
      
      final mockUser = User(
        id: 'demo-user-123',
        email: 'demo@example.com',
        displayName: 'Demo User',
        fullName: 'Demo User',
        avatar: null,
        role: UserRole.user,
        isEmailVerified: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        preferences: {
          'theme': 'light',
          'notifications': true,
          'language': 'en',
        },
      );
      
      await _saveTokensSecurely(mockAccessToken, mockRefreshToken);
      await _saveUserDataSecurely(mockUser);
      
      print('Demo session created successfully');
      
      return AuthResponse(
        user: mockUser,
        accessToken: mockAccessToken,
        refreshToken: mockRefreshToken,
      );
    } catch (e) {
      print('Error creating demo session: $e');
      throw Exception('Failed to create demo session: $e');
    }
  }

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('Attempting login for: $email');
      
      if (email == 'demo@example.com' && password == 'demo123') {
        print('Demo login detected, using mock response');
        return _createMockAuthResponse();
      }
      
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response received: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
      
      return _processAuthResponse(response.data, 'login');
    } catch (e) {
      print('Login failed: $e');
      
      if (email == 'demo@example.com' && password == 'demo123') {
        print('API failed, using mock demo response');
        return _createMockAuthResponse();
      }
      
      try {
        await _secureStorage.clearTokens();
      } catch (cleanupError) {
        print('Error during login cleanup: $cleanupError');
      }
      
      throw _createUserFriendlyException(e);
    }
  }

  // Mock auth response for demo
  AuthResponse _createMockAuthResponse() {
    print('Creating mock auth response for demo');
    
    final mockUser = User(
      id: 'demo-user-123',
      email: 'demo@example.com',
      displayName: 'Demo User',
      fullName: 'Demo User',
      avatar: null,
      role: UserRole.user,
      isEmailVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      preferences: {
        'theme': 'light',
        'notifications': true,
        'language': 'en',
      },
    );
    
    const mockAccessToken = 'demo_access_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo';
    const mockRefreshToken = 'demo_refresh_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo';
    
    return AuthResponse(
      user: mockUser,
      accessToken: mockAccessToken,
      refreshToken: mockRefreshToken,
    );
  }

  // Process auth response
  Future<AuthResponse> _processAuthResponse(dynamic responseData, String operation) async {
    Map<String, dynamic> authData;
    
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          authData = data;
        } else {
          throw Exception('Invalid data structure in $operation response');
        }
      } else {
        authData = responseData;
      }
    } else {
      throw Exception('Invalid response format: ${responseData.runtimeType}');
    }

    print('Processing auth data: ${authData.keys}');

    if (!authData.containsKey('user')) {
      throw Exception('No user data in $operation response');
    }

    final authResponse = AuthResponse.fromJson(authData);
    
    if (authResponse.accessToken.isEmpty) {
      throw Exception('No access token received from $operation');
    }
    
    if (authResponse.refreshToken.isEmpty) {
      throw Exception('No refresh token received from $operation');
    }
    
    await _saveTokensSecurely(authResponse.accessToken, authResponse.refreshToken);
    await _saveUserDataSecurely(authResponse.user);

    print('$operation completed successfully for: ${authResponse.user.email}');
    return authResponse;
  }

  // Save tokens securely
  Future<void> _saveTokensSecurely(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.saveTokens(accessToken, refreshToken);
      print('Tokens saved successfully');
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      for (int i = 0; i < 3; i++) {
        final savedAccessToken = await _secureStorage.getAccessToken();
        final savedRefreshToken = await _secureStorage.getRefreshToken();
        
        if (savedAccessToken == accessToken && savedRefreshToken == refreshToken) {
          print('Token save verification successful');
          return;
        }
        
        if (i < 2) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      print('Warning: Token verification uncertain, but continuing...');
    } catch (e) {
      print('Error saving tokens: $e');
      print('Continuing despite token save error - will verify on next use');
    }
  }

  // Save user data securely
  Future<void> _saveUserDataSecurely(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureStorage.saveUserData(userJson);
      print('User data saved successfully');
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      for (int i = 0; i < 3; i++) {
        final savedUserData = await _secureStorage.getUserData();
        
        if (savedUserData != null && savedUserData.isNotEmpty) {
          try {
            final parsedUser = User.fromJson(jsonDecode(savedUserData));
            if (parsedUser.id == user.id && parsedUser.email == user.email) {
              print('User data save verification successful');
              return;
            }
          } catch (parseError) {
            print('User data parse error during verification: $parseError');
          }
        }
        
        if (i < 2) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      print('Warning: User data verification uncertain, but continuing...');
    } catch (e) {
      print('Error saving user data: $e');
      print('Continuing despite user data save error - will verify on next use');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('No access token found');
        return null;
      }

      print('Getting current user with token: ${accessToken.substring(0, 20)}...');

      if (accessToken.startsWith('demo_access_token_')) {
        print('Demo token detected, returning mock user');
        return _getMockDemoUser();
      }

      final userData = await _secureStorage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        try {
          final userJson = jsonDecode(userData);
          final cachedUser = User.fromJson(userJson);
          print('Found cached user: ${cachedUser.email}');
          
          if (cachedUser.email == 'demo@example.com') {
            return cachedUser;
          }
          
          try {
            final response = await _apiClient.get('/auth/me');
            if (response.statusCode == 200) {
              return cachedUser;
            } else {
              print('Cached user validation failed, fetching fresh data');
            }
          } catch (e) {
            print('Cache validation error: $e');
          }
        } catch (e) {
          print('Error parsing cached user data: $e');
        }
      }

      print('Fetching user data from server...');
      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get user data: ${response.statusCode}');
      }
      
      final user = _parseUserFromResponse(response.data);
      await _saveUserDataSecurely(user);
      
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      
      if (_isAuthError(e)) {
        print('Authentication error - clearing tokens');
        await _secureStorage.clearTokens();
      }
      
      return null;
    }
  }

  // Get mock demo user
  User _getMockDemoUser() {
    return User(
      id: 'demo-user-123',
      email: 'demo@example.com',
      displayName: 'Demo User',
      fullName: 'Demo User',
      avatar: null,
      role: UserRole.user,
      isEmailVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      preferences: {
        'theme': 'light',
        'notifications': true,
        'language': 'en',
      },
    );
  }

  // Parse user from API response
  User _parseUserFromResponse(dynamic responseData) {
    Map<String, dynamic> userData;
    
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data.containsKey('user')) {
          userData = data['user'] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          userData = data;
        } else {
          throw Exception('Invalid user data structure in response');
        }
      } else if (responseData.containsKey('user')) {
        userData = responseData['user'] as Map<String, dynamic>;
      } else {
        userData = responseData;
      }
    } else {
      throw Exception('Invalid response format: ${responseData.runtimeType}');
    }
    
    return User.fromJson(userData);
  }

  // Logout
  Future<void> logout() async {
    try {
      print('Starting logout process...');
      
      final refreshToken = await _secureStorage.getRefreshToken();
      final accessToken = await _secureStorage.getAccessToken();
      
      await _secureStorage.clearTokens();
      print('Local tokens cleared');
      
      if (accessToken?.startsWith('demo_access_token_') == true) {
        print('Demo token logout - skipping server call');
        return;
      }
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _apiClient.post(
            '/auth/logout',
            data: {'refreshToken': refreshToken},
          );
          print('Server logout successful');
        } catch (e) {
          print('Server logout failed (non-critical): $e');
        }
      }
    } catch (e) {
      print('Logout error: $e');
      try {
        await _secureStorage.clearTokens();
      } catch (clearError) {
        print('Critical: Failed to clear tokens: $clearError');
      }
    }
  }

  // Update profile
  Future<User> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      print('Updating profile...');
      
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      if (token.startsWith('demo_access_token_')) {
        print('Demo token detected, returning mock updated user');
        final currentUser = _getMockDemoUser();
        
        final updatedUser = User(
          id: currentUser.id,
          email: currentUser.email,
          displayName: currentUser.displayName,
          fullName: fullName ?? currentUser.fullName,
          avatar: avatar ?? currentUser.avatar,
          role: currentUser.role,
          isEmailVerified: currentUser.isEmailVerified,
          isActive: currentUser.isActive,
          createdAt: currentUser.createdAt,
          updatedAt: DateTime.now(),
          preferences: preferences ?? currentUser.preferences,
        );
        
        await _saveUserDataSecurely(updatedUser);
        return updatedUser;
      }
      
      final requestData = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) requestData['fullName'] = fullName;
      if (avatar != null) requestData['avatar'] = avatar;
      if (preferences != null) requestData['preferences'] = preferences;
      
      if (requestData.isEmpty) {
        throw Exception('No data provided for update');
      }
      
      final response = await _apiClient.put(
        '/users/profile',
        data: requestData,
      );

      if (response.statusCode != 200) {
        throw Exception('Profile update failed with status: ${response.statusCode}');
      }

      final user = _parseUserFromResponse(response.data);
      await _saveUserDataSecurely(user);
      
      return user;
    } catch (e) {
      print('Profile update failed: $e');
      
      if (_isAuthError(e)) {
        await _secureStorage.clearTokens();
        throw Exception('Session expired. Please log in again.');
      }
      
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('Changing password...');
      
      if (currentPassword.isEmpty) {
        throw Exception('Current password is required');
      }
      
      if (newPassword.length < 8) {
        throw Exception('New password must be at least 8 characters long');
      }
      
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.startsWith('demo_access_token_')) {
        print('Demo token detected, simulating password change success');
        return;
      }
      
      final response = await _apiClient.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Password change failed with status: ${response.statusCode}');
      }
      
      print('Password changed successfully');
    } catch (e) {
      print('Password change failed: $e');
      
      if (e.toString().contains('401')) {
        throw Exception('Current password is incorrect');
      } else if (e.toString().contains('400')) {
        throw Exception('Invalid password format');
      }
      
      throw Exception('Failed to change password: $e');
    }
  }

  // Refresh token (private method)
  Future<RefreshTokenResponse> _refreshToken() async {
    try {
      print('Refreshing token...');
      
      final refreshTokenValue = await _secureStorage.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        throw Exception('No refresh token available');
      }

      if (refreshTokenValue.startsWith('demo_refresh_token_')) {
        print('Demo refresh token detected, returning mock response');
        const mockAccessToken = 'demo_access_token_refreshed';
        const mockRefreshToken = 'demo_refresh_token_refreshed';
        
        final refreshResponse = RefreshTokenResponse(
          accessToken: mockAccessToken,
          refreshToken: mockRefreshToken,
        );
        
        await _saveTokensSecurely(refreshResponse.accessToken, refreshResponse.refreshToken);
        
        return refreshResponse;
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshTokenValue},
      );

      if (response.statusCode != 200) {
        throw Exception('Token refresh failed with status: ${response.statusCode}');
      }

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
      
      if (refreshResponse.accessToken.isEmpty || refreshResponse.refreshToken.isEmpty) {
        throw Exception('Invalid tokens received from refresh');
      }
      
      await _saveTokensSecurely(refreshResponse.accessToken, refreshResponse.refreshToken);
      
      print('Token refresh successful');
      return refreshResponse;
    } catch (e) {
      print('Token refresh failed: $e');
      await _secureStorage.clearTokens();
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Public refresh token method
  Future<RefreshTokenResponse> refreshToken() async {
    return await _refreshToken();
  }

  // Demo login helper
  Future<AuthResponse> demoLogin() async {
    print('Attempting demo login...');
    return await createDemoSession();
  }

  // Helper methods
  bool _isAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') || 
           errorStr.contains('unauthorized') ||
           errorStr.contains('no token provided') ||
           errorStr.contains('invalid token') ||
           errorStr.contains('token expired');
  }

  Exception _createUserFriendlyException(dynamic error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('400')) {
      return Exception('Invalid request. Please check your input.');
    } else if (errorStr.contains('401')) {
      return Exception('Authentication failed. Please check your credentials.');
    } else if (errorStr.contains('429')) {
      return Exception('Too many attempts. Please try again later.');
    } else if (errorStr.contains('Network') || errorStr.contains('connection')) {
      return Exception('Network error. Please check your internet connection.');
    } else {
      return Exception('Operation failed. Please try again.');
    }
  }

  Future<Map<String, String?>> getStoredTokens() async {
    return {
      'accessToken': await _secureStorage.getAccessToken(),
      'refreshToken': await _secureStorage.getRefreshToken(),
    };
  }
}