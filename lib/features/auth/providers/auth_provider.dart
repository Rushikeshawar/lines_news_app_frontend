// lib/features/auth/providers/auth_provider.dart - COMPLETE WORKING VERSION
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthRepository(apiClient, secureStorage);
});

// Auth state notifier with improved initialization and state management
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  bool _isInitialized = false;
  bool _isInitializing = false;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  // Improved initialization without loops
  Future<void> _initializeAuth() async {
    if (_isInitialized || _isInitializing) {
      print('Auth already initialized or initializing, skipping...');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('Initializing authentication...');
      
      // Check if we have valid tokens
      final hasValidTokens = await _repository.hasValidToken();
      
      if (!hasValidTokens) {
        print('No valid tokens found - user not authenticated');
        state = const AsyncValue.data(null);
        _isInitialized = true;
        _isInitializing = false;
        return;
      }

      // Try to get current user with valid tokens
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('User authenticated: ${user.email} (${user.role.displayName})');
        state = AsyncValue.data(user);
      } else {
        print('Failed to get current user despite valid tokens');
        // Clear potentially corrupted tokens
        await _repository.logout();
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      print('Auth initialization failed: $e');
      // Clear potentially corrupted tokens on any error
      try {
        await _repository.logout();
      } catch (cleanupError) {
        print('Error during initialization cleanup: $cleanupError');
      }
      state = const AsyncValue.data(null);
    } finally {
      _isInitialized = true;
      _isInitializing = false;
    }
  }

  // FIXED: Login with simplified logic and demo support
  Future<void> login(String email, String password) async {
    print('Login method called with email: $email');
    
    // Allow retries, but prevent concurrent logins of the same type
    if (state.isLoading) {
      print('Login already in progress');
      return;
    }

    print('Setting loading state...');
    state = const AsyncValue.loading();
    
    try {
      AuthResponse loginResponse;
      
      // For demo login, use direct demo session creation
      if (email == 'demo@example.com' && password == 'demo123') {
        print('Demo login detected - creating demo session');
        loginResponse = await _repository.createDemoSession();
      } else {
        // For real login, attempt API call
        loginResponse = await _repository.login(email, password);
      }
      
      print('Login successful for: ${loginResponse.user.email}');
      
      // Set state directly with the user from the response
      state = AsyncValue.data(loginResponse.user);
      print('User authenticated and state updated successfully');
      
    } catch (error, stackTrace) {
      print('Login failed: $error');
      
      // Ensure clean state on failure
      try {
        await _repository.logout();
      } catch (cleanupError) {
        print('Error during login failure cleanup: $cleanupError');
      }
      
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Register with proper error handling
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    if (state.isLoading) {
      print('Registration already in progress');
      return;
    }

    print('Starting registration for: $email');
    state = const AsyncValue.loading();
    
    try {
      final registerResponse = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      print('Registration successful for: ${registerResponse.user.email}');
      
      // Set state directly with the user from the response
      state = AsyncValue.data(registerResponse.user);
      print('User registered and state updated successfully');
      
    } catch (error, stackTrace) {
      print('Registration failed: $error');
      
      // Ensure clean state on failure
      try {
        await _repository.logout();
      } catch (cleanupError) {
        print('Error during registration failure cleanup: $cleanupError');
      }
      
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Logout with immediate state clearing
  Future<void> logout() async {
    print('Starting logout process...');
    
    try {
      // Clear local state immediately to prevent UI issues
      state = const AsyncValue.data(null);
      
      // Then perform cleanup
      await _repository.logout();
      print('Logout completed successfully');
    } catch (error) {
      print('Logout error: $error');
      // State is already cleared, so this is not critical for UI
    }
  }

  // Force logout for error scenarios
  Future<void> forceLogout() async {
    print('Force logout triggered');
    
    // Clear state immediately
    state = const AsyncValue.data(null);
    
    try {
      // Clear all stored data
      await _repository.logout();
      print('Force logout completed');
    } catch (e) {
      print('Error during force logout: $e');
      // State is already cleared, continue anyway
    }
  }

  // Refresh user data with better error handling
  Future<void> refreshUser() async {
    if (!_isInitialized) {
      print('Auth not initialized, skipping user refresh');
      return;
    }

    final currentUser = state.value;
    if (currentUser == null) {
      print('No current user to refresh');
      return;
    }

    try {
      print('Refreshing user data...');
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        state = AsyncValue.data(user);
        print('User data refreshed successfully');
      } else {
        print('No user found during refresh - logging out');
        await forceLogout();
      }
    } catch (e, stackTrace) {
      print('User refresh failed: $e');
      
      // Check if it's an auth error
      if (_isAuthError(e)) {
        print('Auth error during refresh - forcing logout');
        await forceLogout();
      } else {
        // For non-auth errors, just log but keep current state
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Update profile with proper error handling
  Future<void> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) {
      print('No current user to update profile');
      throw Exception('No authenticated user');
    }

    try {
      print('Updating profile...');
      final updatedUser = await _repository.updateProfile(
        fullName: fullName,
        avatar: avatar,
        preferences: preferences,
      );
      
      state = AsyncValue.data(updatedUser);
      print('Profile updated successfully');
    } catch (error, stackTrace) {
      print('Profile update failed: $error');
      
      // Check if it's an auth error
      if (_isAuthError(error)) {
        await forceLogout();
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  // Change password with proper error handling
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.value == null) {
      throw Exception('No authenticated user');
    }

    try {
      print('Changing password...');
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      print('Password changed successfully');
    } catch (error) {
      print('Password change failed: $error');
      
      // Check if it's an auth error
      if (_isAuthError(error)) {
        await forceLogout();
      }
      
      rethrow;
    }
  }

  // Demo login with better error handling
  Future<void> demoLogin() async {
    print('Starting demo login...');
    await login('demo@example.com', 'demo123');
  }

  // Helper method to check for authentication errors
  bool _isAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') || 
           errorStr.contains('unauthorized') ||
           errorStr.contains('no token provided') ||
           errorStr.contains('invalid token') ||
           errorStr.contains('token expired');
  }

  // Check if user has specific role
  bool hasRole(UserRole role) {
    final user = state.value;
    return user?.hasRole(role) ?? false;
  }

  // Get user display name
  String get userDisplayName {
    final user = state.value;
    return user?.name ?? 'User';
  }

  // Check if authenticated
  bool get isAuthenticated {
    return state.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  // Get current user safely
  User? get currentUser {
    return state.value;
  }
}

// Auth provider with proper initialization
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).value;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// User role provider
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).value?.role;
});

// Auth loading provider
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});

// Auth error provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// Auth actions provider with enhanced error handling
final authActionsProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return AuthActions(authNotifier);
});

class AuthActions {
  final AuthNotifier _authNotifier;

  AuthActions(this._authNotifier);

  Future<void> login(String email, String password) {
    return _authNotifier.login(email, password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _authNotifier.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<void> logout() {
    return _authNotifier.logout();
  }

  Future<void> forceLogout() {
    return _authNotifier.forceLogout();
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) {
    return _authNotifier.updateProfile(
      fullName: fullName,
      avatar: avatar,
      preferences: preferences,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authNotifier.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> refreshUser() {
    return _authNotifier.refreshUser();
  }

  Future<void> demoLogin() {
    return _authNotifier.demoLogin();
  }

  bool get isAuthenticated => _authNotifier.isAuthenticated;
  User? get currentUser => _authNotifier.currentUser;
  String get userDisplayName => _authNotifier.userDisplayName;
  bool hasRole(UserRole role) => _authNotifier.hasRole(role);
}

// User preferences provider
final userPreferencesProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.preferences ?? {};
});

// Theme preference provider
final themePreferenceProvider = Provider<String>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences['theme'] as String? ?? 'light';
});

// Auth status provider for debugging
final authStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final authState = ref.watch(authProvider);
  return {
    'isAuthenticated': authState.value != null,
    'isLoading': authState.isLoading,
    'hasError': authState.hasError,
    'error': authState.hasError ? authState.error.toString() : null,
    'user': authState.value?.toJson(),
  };
});