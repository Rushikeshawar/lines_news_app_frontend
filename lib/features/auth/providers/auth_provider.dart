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
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final loginResponse = await _repository.login(email, password);
      state = AsyncValue.data(loginResponse.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final registerResponse = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      state = AsyncValue.data(registerResponse.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      // Even if logout fails on server, clear local state
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logoutAll() async {
    try {
      await _repository.logoutAll();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      // Don't change state on error, user might still be valid
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.updateProfile(
        fullName: fullName,
        avatar: avatar,
        preferences: preferences,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error) {
      rethrow;
    }
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
  return ref.watch(authProvider).value != null;
});

// User role provider
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).value?.role;
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