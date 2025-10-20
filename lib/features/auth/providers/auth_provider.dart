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
      
      final tokens = await _repository.getStoredTokens();
      final accessToken = tokens['accessToken'];
      final refreshToken = tokens['refreshToken'];
      
      if ((accessToken == null || accessToken.isEmpty) && 
          (refreshToken == null || refreshToken.isEmpty)) {
        print('No tokens found - user not authenticated');
        state = const AsyncValue.data(null);
        _isInitialized = true;
        return;
      }

      print('Tokens found, attempting to get user...');
      
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        print('User authenticated: ${user.email}');
        state = AsyncValue.data(user);
      } else {
        print('Failed to get user, clearing tokens');
        await _repository.logout();
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      print('Auth initialization error: $e');
      if (_isAuthError(e)) {
        print('Auth error detected, clearing tokens');
        await _repository.logout();
      }
      state = const AsyncValue.data(null);
    } finally {
      _isInitialized = true;
    }
  }

  // ==========================================
  // OTP-BASED REGISTRATION METHODS
  // ==========================================
  
  Future<OTPResponse> requestRegistrationOTP({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      print('Requesting registration OTP for: $email');
      return await _repository.requestRegistrationOTP(
        email: email,
        fullName: fullName,
        password: password,
      );
    } catch (error) {
      print('Request OTP failed: $error');
      rethrow;
    }
  }

  Future<void> verifyOTPAndRegister({
    required String email,
    required String otp,
    UserRole role = UserRole.user,
  }) async {
    if (state.isLoading) return;

    print('Verifying OTP and registering: $email');
    state = const AsyncValue.loading();
    
    try {
      final authResponse = await _repository.verifyOTPAndRegister(
        email: email,
        otp: otp,
        role: role,
      );
      print('Registration successful: ${authResponse.user.email}');
      state = AsyncValue.data(authResponse.user);
    } catch (error, stackTrace) {
      print('OTP verification failed: $error');
      await _repository.logout();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<OTPResponse> resendOTP(String email) async {
    try {
      print('Resending OTP for: $email');
      return await _repository.resendOTP(email);
    } catch (error) {
      print('Resend OTP failed: $error');
      rethrow;
    }
  }

  // ==========================================
  // PASSWORD RESET WITH OTP
  // ==========================================
  
  Future<OTPResponse> requestPasswordResetOTP(String email) async {
    try {
      print('Requesting password reset OTP for: $email');
      return await _repository.requestPasswordResetOTP(email);
    } catch (error) {
      print('Request password reset OTP failed: $error');
      rethrow;
    }
  }

  Future<void> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      print('Verifying password reset OTP for: $email');
      await _repository.verifyPasswordResetOTP(
        email: email,
        otp: otp,
      );
    } catch (error) {
      print('Verify password reset OTP failed: $error');
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      print('Resetting password for: $email');
      await _repository.resetPassword(
        email: email,
        newPassword: newPassword,
      );
    } catch (error) {
      print('Reset password failed: $error');
      rethrow;
    }
  }

  // ==========================================
  // EXISTING AUTH METHODS
  // ==========================================

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
    state = const AsyncValue.loading();
    
    try {
      final loginResponse = await _repository.createDemoSession();
      print('Demo login successful: ${loginResponse.user.email}');
      state = AsyncValue.data(loginResponse.user);
    } catch (error, stackTrace) {
      print('Demo login failed: $error');
      await _repository.logout();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    print('Logout started');
    state = const AsyncValue.data(null);
    await _repository.logout();
  }

  bool get isAuthenticated => state.value != null;
  User? get currentUser => state.value;

  bool _isAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') || 
           errorStr.contains('unauthorized') ||
           errorStr.contains('token');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});