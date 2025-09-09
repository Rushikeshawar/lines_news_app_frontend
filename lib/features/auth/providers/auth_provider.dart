// lib/features/auth/providers/auth_provider.dart - FIXED VERSION
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../articles/models/article_model.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthRepository(apiClient, secureStorage);
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      print('🔍 Checking authentication state...');
      final user = await _repository.getCurrentUser();
      print('👤 Current user: ${user?.email ?? "None"}');
      state = AsyncValue.data(user);
    } catch (e) {
      print('❌ Auth state check failed: $e');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    print('🔐 Starting login process for: $email');
    state = const AsyncValue.loading();
    
    try {
      final loginResponse = await _repository.login(email, password);
      print('✅ Login successful for: ${loginResponse.user.email}');
      state = AsyncValue.data(loginResponse.user);
    } catch (error, stackTrace) {
      print('❌ Login failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    print('📝 Starting registration for: $email');
    state = const AsyncValue.loading();
    
    try {
      final registerResponse = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      print('✅ Registration successful for: ${registerResponse.user.email}');
      state = AsyncValue.data(registerResponse.user);
    } catch (error, stackTrace) {
      print('❌ Registration failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    print('🚪 Starting logout process...');
    try {
      await _repository.logout();
      print('✅ Logout successful');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      print('⚠️ Logout error: $error');
      // Even if logout fails on server, clear local state
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logoutAll() async {
    print('🚪 Starting logout all devices...');
    try {
      await _repository.logoutAll();
      print('✅ Logout all devices successful');
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      print('⚠️ Logout all error: $error');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> refreshUser() async {
    try {
      print('🔄 Refreshing user data...');
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AsyncValue.data(user);
        print('✅ User data refreshed');
      } else {
        print('⚠️ No user found during refresh');
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      print('⚠️ User refresh failed: $e');
      // Don't change state on error, user might still be valid
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) {
      print('⚠️ No current user to update profile');
      return;
    }

    try {
      print('👤 Updating profile...');
      final updatedUser = await _repository.updateProfile(
        fullName: fullName,
        avatar: avatar,
        preferences: preferences,
      );
      state = AsyncValue.data(updatedUser);
      print('✅ Profile updated successfully');
    } catch (error, stackTrace) {
      print('❌ Profile update failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔑 Changing password...');
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      print('✅ Password changed successfully');
    } catch (error) {
      print('❌ Password change failed: $error');
      rethrow;
    }
  }

  // Demo login helper
  Future<void> demoLogin() async {
    print('🎮 Starting demo login...');
    await login('demo@example.com', 'demo123');
  }

  // Force logout (for error handling)
  void forceLogout() {
    print('🔴 Force logout triggered');
    state = const AsyncValue.data(null);
  }

  // Check if user has specific role
  bool hasRole(UserRole role) {
    final user = state.value;
    return user?.role == role;
  }

  // Get user display name
  String get userDisplayName {
    final user = state.value;
    return user?.displayName ?? 'User';
  }
}

// Auth provider
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

// Auth actions provider
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

  Future<void> logoutAll() {
    return _authNotifier.logoutAll();
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

  void forceLogout() {
    _authNotifier.forceLogout();
  }
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

// Notification preferences provider
final notificationPreferencesProvider = Provider<Map<String, dynamic>>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences['notifications'] as Map<String, dynamic>? ?? {
    'email': true,
    'push': true,
  };
});

// Language preference provider
final languagePreferenceProvider = Provider<String>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences['language'] as String? ?? 'en';
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