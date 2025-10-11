// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AuthRepository(apiClient, secureStorage);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  bool _isInitialized = false;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
    
    try {
      print('Initializing authentication...');
      
      final hasValidTokens = await _repository.hasValidToken();
      
      if (!hasValidTokens) {
        print('No valid tokens - user not authenticated');
        state = const AsyncValue.data(null);
        _isInitialized = true;
        return;
      }

      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('User authenticated: ${user.email}');
        state = AsyncValue.data(user);
      } else {
        await _repository.logout();
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      print('Auth initialization failed: $e');
      await _repository.logout();
      state = const AsyncValue.data(null);
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> login(String email, String password) async {
    if (state.isLoading) return;

    print('Login started for: $email');
    state = const AsyncValue.loading();
    
    try {
      final loginResponse = await _repository.login(email, password);
      print('Login successful: ${loginResponse.user.email}');
      state = AsyncValue.data(loginResponse.user);
    } catch (error, stackTrace) {
      print('Login failed: $error');
      await _repository.logout();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.user,
  }) async {
    if (state.isLoading) return;

    print('Registration started for: $email');
    state = const AsyncValue.loading();
    
    try {
      final registerResponse = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      print('Registration successful: ${registerResponse.user.email}');
      state = AsyncValue.data(registerResponse.user);
    } catch (error, stackTrace) {
      print('Registration failed: $error');
      await _repository.logout();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatar,
    Map<String, dynamic>? preferences,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) {
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
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

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
      rethrow;
    }
  }

  Future<void> demoLogin() async {
    print('Demo login started');
    await login('demo@example.com', 'demo123');
  }

  Future<void> logout() async {
    print('Logout started');
    state = const AsyncValue.data(null);
    await _repository.logout();
  }

  bool get isAuthenticated => state.value != null;
  User? get currentUser => state.value;
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});