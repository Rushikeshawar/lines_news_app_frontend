// lib/core/storage/secure_storage.dart - WEB-COMPATIBLE VERSION
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';

class SecureStorage {
  static FlutterSecureStorage? _storage;
  
  static FlutterSecureStorage get _instance {
    if (_storage == null) {
      if (kIsWeb) {
        // Web-specific configuration with reduced security for compatibility
        _storage = const FlutterSecureStorage(
          webOptions: WebOptions(
            dbName: "lines_news_secure_storage",
            publicKey: "lines_news_public_key",
          ),
        );
      } else {
        // Mobile configuration with full security
        _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );
      }
    }
    return _storage!;
  }

  // Token management with error handling
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await Future.wait([
        _instance.write(key: AppConstants.accessTokenKey, value: accessToken),
        _instance.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tokens: $e');
      }
      // Fallback: Don't throw error, just log it
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _instance.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading access token: $e');
      }
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _instance.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading refresh token: $e');
      }
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _instance.delete(key: AppConstants.accessTokenKey),
        _instance.delete(key: AppConstants.refreshTokenKey),
        _instance.delete(key: AppConstants.userDataKey),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing tokens: $e');
      }
      // Continue anyway
    }
  }

  // User data management with error handling
  Future<void> saveUserData(String userData) async {
    try {
      await _instance.write(key: AppConstants.userDataKey, value: userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<String?> getUserData() async {
    try {
      return await _instance.read(key: AppConstants.userDataKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading user data: $e');
      }
      return null;
    }
  }

  // Generic storage methods with error handling
  Future<void> write(String key, String value) async {
    try {
      await _instance.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        print('Error writing key $key: $e');
      }
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _instance.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading key $key: $e');
      }
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _instance.delete(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting key $key: $e');
      }
    }
  }

  Future<void> deleteAll() async {
    try {
      await _instance.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all keys: $e');
      }
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      return await _instance.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error reading all keys: $e');
      }
      return {};
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return await _instance.containsKey(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking key $key: $e');
      }
      return false;
    }
  }

  // Test storage functionality
  Future<bool> testStorage() async {
    try {
      const testKey = 'test_key';
      const testValue = 'test_value';
      
      await write(testKey, testValue);
      final result = await read(testKey);
      await delete(testKey);
      
      return result == testValue;
    } catch (e) {
      if (kDebugMode) {
        print('Storage test failed: $e');
      }
      return false;
    }
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});