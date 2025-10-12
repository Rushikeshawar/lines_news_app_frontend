// lib/features/auth/repositories/auth_repository.dart - FIXED VERSION
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  // Token validation with better error handling
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
      
      // Test token validity with the /auth/me endpoint
      try {
        final response = await _apiClient.get('/auth/me');
        print('Token validation successful: ${response.statusCode}');
        return response.statusCode == 200;
      } catch (e) {
        print('Token validation failed: $e');
        
        // If 401, try to refresh token
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

  // NEW: Create demo session directly (bypasses API)
  Future<AuthResponse> createDemoSession() async {
    print('Creating demo session directly...');
    
    try {
      // Clear any existing tokens first
      await _secureStorage.clearTokens();
      
      // Create mock tokens
      const mockAccessToken = 'demo_access_token_' + 
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwiaWF0IjoxNjk5OTk5OTk5fQ.demo_signature';
      const mockRefreshToken = 'demo_refresh_token_' + 
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwidHlwZSI6InJlZnJlc2gifQ.demo_refresh_signature';
      
      // Create mock user
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
      
      // Save tokens and user data
      await _saveTokensSecurely(mockAccessToken, mockRefreshToken);
      await _saveUserDataSecurely(mockUser);
      
      print('Demo session created successfully');
      
      // Return auth response
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

  // Enhanced login with comprehensive error handling and mock fallback
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('Attempting login for: $email');
      
      // For demo purposes, check if this is a demo login
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
      
      // For demo purposes, fall back to mock response if API is unavailable
      if (email == 'demo@example.com' && password == 'demo123') {
        print('API failed, using mock demo response');
        return _createMockAuthResponse();
      }
      
      // Clean up any partial data on failure
      try {
        await _secureStorage.clearTokens();
      } catch (cleanupError) {
        print('Error during login cleanup: $cleanupError');
      }
      
      throw _createUserFriendlyException(e);
    }
  }

  // Mock auth response for demo purposes
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
    
    const mockAccessToken = 'demo_access_token_' + 
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwiaWF0IjoxNjk5OTk5OTk5fQ.demo_signature';
    const mockRefreshToken = 'demo_refresh_token_' + 
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwidHlwZSI6InJlZnJlc2gifQ.demo_refresh_signature';
    
    return AuthResponse(
      user: mockUser,
      accessToken: mockAccessToken,
      refreshToken: mockRefreshToken,
    );
  }

  // Centralized auth response processing
  Future<AuthResponse> _processAuthResponse(dynamic responseData, String operation) async {
    // Handle different response structures
    Map<String, dynamic> authData;
    
    if (responseData is Map<String, dynamic>) {
      // Check if data is nested under 'data' key
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

    // Validate required fields
    if (!authData.containsKey('user')) {
      throw Exception('No user data in $operation response');
    }

    final authResponse = AuthResponse.fromJson(authData);
    
    // Validate tokens
    if (authResponse.accessToken.isEmpty) {
      throw Exception('No access token received from $operation');
    }
    
    if (authResponse.refreshToken.isEmpty) {
      throw Exception('No refresh token received from $operation');
    }
    
    // Save tokens with verification (non-blocking for web)
    await _saveTokensSecurely(authResponse.accessToken, authResponse.refreshToken);
    
    // Save user data with verification (non-blocking for web)
    await _saveUserDataSecurely(authResponse.user);

    print('$operation completed successfully for: ${authResponse.user.email}');
    return authResponse;
  }

  // Secure token saving with verification (web-friendly)
  Future<void> _saveTokensSecurely(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.saveTokens(accessToken, refreshToken);
      print('Tokens saved successfully');
      
      // Add a small delay for web storage to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify tokens were saved correctly (with retries for web)
      for (int i = 0; i < 3; i++) {
        final savedAccessToken = await _secureStorage.getAccessToken();
        final savedRefreshToken = await _secureStorage.getRefreshToken();
        
        if (savedAccessToken == accessToken && savedRefreshToken == refreshToken) {
          print('Token save verification successful');
          return;
        }
        
        if (i < 2) {
          // Wait a bit and retry
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      // If we get here, verification failed but tokens might still be saved
      print('Warning: Token verification uncertain, but continuing...');
    } catch (e) {
      print('Error saving tokens: $e');
      // Don't throw - tokens might still be saved despite verification issues
      print('Continuing despite token save error - will verify on next use');
    }
  }

  // Secure user data saving with verification (web-friendly)
  Future<void> _saveUserDataSecurely(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _secureStorage.saveUserData(userJson);
      print('User data saved successfully');
      
      // Add a small delay for web storage to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify user data was saved correctly (with retries for web)
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
          // Wait a bit and retry
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      // If we get here, verification failed but data might still be saved
      print('Warning: User data verification uncertain, but continuing...');
    } catch (e) {
      print('Error saving user data: $e');
      // Don't throw - data might still be saved despite verification issues
      print('Continuing despite user data save error - will verify on next use');
    }
  }

  // Enhanced getCurrentUser with better caching and mock support
  Future<User?> getCurrentUser() async {
    try {
      // First check if we have valid tokens
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('No access token found');
        return null;
      }

      print('Getting current user with token: ${accessToken.substring(0, 20)}...');

      // Check if this is a demo token
      if (accessToken.startsWith('demo_access_token_')) {
        print('Demo token detected, returning mock user');
        return _getMockDemoUser();
      }

      // Try to get user from cache first
      final userData = await _secureStorage.getUserData();
      if (userData != null && userData.isNotEmpty) {
        try {
          final userJson = jsonDecode(userData);
          final cachedUser = User.fromJson(userJson);
          print('Found cached user: ${cachedUser.email}');
          
          // For demo users, return cached data immediately
          if (cachedUser.email == 'demo@example.com') {
            return cachedUser;
          }
          
          // Verify cache is still valid by making a quick API call
          try {
            final response = await _apiClient.get('/auth/me');
            if (response.statusCode == 200) {
              return cachedUser;
            } else {
              print('Cached user validation failed, fetching fresh data');
            }
          } catch (e) {
            print('Cache validation error: $e');
            // Continue to fetch from server
          }
        } catch (e) {
          print('Error parsing cached user data: $e');
          // Continue to fetch from server
        }
      }

      // Fetch from server
      print('Fetching user data from server...');
      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get user data: ${response.statusCode}');
      }
      
      final user = _parseUserFromResponse(response.data);
      
      // Cache the fresh user data
      await _saveUserDataSecurely(user);
      
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      
      // If server request fails with auth error, clear tokens
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

  // Enhanced logout with better cleanup
  Future<void> logout() async {
    try {
      print('Starting logout process...');
      
      // Get tokens before clearing them
      final refreshToken = await _secureStorage.getRefreshToken();
      final accessToken = await _secureStorage.getAccessToken();
      
      // Always clear local storage first to prevent UI issues
      await _secureStorage.clearTokens();
      print('Local tokens cleared');
      
      // Skip server logout for demo tokens
      if (accessToken?.startsWith('demo_access_token_') == true) {
        print('Demo token logout - skipping server call');
        return;
      }
      
      // Try to notify server about logout
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _apiClient.post(
            '/auth/logout',
            data: {'refreshToken': refreshToken},
          );
          print('Server logout successful');
        } catch (e) {
          print('Server logout failed (non-critical): $e');
          // This is not critical since local tokens are already cleared
        }
      }
    } catch (e) {
      print('Logout error: $e');
      // Ensure tokens are cleared even if there's an error
      try {
        await _secureStorage.clearTokens();
      } catch (clearError) {
        print('Critical: Failed to clear tokens: $clearError');
      }
    }
  }

  // Enhanced registration with better validation
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    try {
      print('Attempting registration for: $email');
      
      // Validate input data
      _validateRegistrationInput(email, password, fullName);
      
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role.name.toUpperCase(),
        },
      );

      print('Registration response received: ${response.statusCode}');
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Registration failed with status: ${response.statusCode}');
      }
      
      return _processAuthResponse(response.data, 'registration');
      
    } catch (e) {
      print('Registration failed: $e');
      
      // Clean up any partial data on failure
      try {
        await _secureStorage.clearTokens();
      } catch (cleanupError) {
        print('Error during registration cleanup: $cleanupError');
      }
      
      throw _createUserFriendlyException(e);
    }
  }

  // Update profile with better error handling
  Future<User> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      print('Updating profile...');
      
      // Ensure we have a valid token
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      // Check if this is a demo token - return mock updated user
      if (token.startsWith('demo_access_token_')) {
        print('Demo token detected, returning mock updated user');
        final currentUser = _getMockDemoUser();
        
        // Apply updates to mock user
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
        
        // Save updated user data
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
      
      // Update cached user data
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
      
      if (newPassword.length < 6) {
        throw Exception('New password must be at least 6 characters long');
      }
      
      // Check if this is a demo token - simulate success
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

  // Refresh token with better error handling (private method)
  Future<RefreshTokenResponse> _refreshToken() async {
    try {
      print('Refreshing token...');
      
      final refreshTokenValue = await _secureStorage.getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        throw Exception('No refresh token available');
      }

      // Skip refresh for demo tokens
      if (refreshTokenValue.startsWith('demo_refresh_token_')) {
        print('Demo refresh token detected, returning mock response');
        const mockAccessToken = 'demo_access_token_refreshed_' + 
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwiaWF0IjoxNjk5OTk5OTk5fQ.demo_signature_refreshed';
        const mockRefreshToken = 'demo_refresh_token_refreshed_' + 
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkZW1vLXVzZXItMTIzIiwidHlwZSI6InJlZnJlc2gifQ.demo_refresh_signature_refreshed';
        
        final refreshResponse = RefreshTokenResponse(
          accessToken: mockAccessToken,
          refreshToken: mockRefreshToken,
        );
        
        // Save new tokens
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
      
      // Validate new tokens
      if (refreshResponse.accessToken.isEmpty || refreshResponse.refreshToken.isEmpty) {
        throw Exception('Invalid tokens received from refresh');
      }
      
      // Save new tokens
      await _saveTokensSecurely(refreshResponse.accessToken, refreshResponse.refreshToken);
      
      print('Token refresh successful');
      return refreshResponse;
    } catch (e) {
      print('Token refresh failed: $e');
      
      // Clear tokens on refresh failure
      await _secureStorage.clearTokens();
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Public method for external refresh token calls
  Future<RefreshTokenResponse> refreshToken() async {
    return await _refreshToken();
  }

  // Demo login helper
  Future<AuthResponse> demoLogin() async {
    print('Attempting demo login...');
    return await createDemoSession();
  }

  // Input validation helper
  void _validateRegistrationInput(String email, String password, String fullName) {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }
    
    if (fullName.isEmpty) {
      throw Exception('Full name is required');
    }
  }

  // Check if error is authentication related
  bool _isAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') || 
           errorStr.contains('unauthorized') ||
           errorStr.contains('no token provided') ||
           errorStr.contains('invalid token') ||
           errorStr.contains('token expired');
  }

  // Create user-friendly exception messages
  Exception _createUserFriendlyException(dynamic error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('400')) {
      return Exception('Invalid email or password');
    } else if (errorStr.contains('401')) {
      return Exception('Authentication failed. Please check your credentials.');
    } else if (errorStr.contains('Network') || errorStr.contains('connection')) {
      return Exception('Network error. Please check your internet connection.');
    } else {
      return Exception('Login failed. Please try again.');
    }
  }

  // Utility methods
  Future<Map<String, String?>> getStoredTokens() async {
    return {
      'accessToken': await _secureStorage.getAccessToken(),
      'refreshToken': await _secureStorage.getRefreshToken(),
    };
  }
}