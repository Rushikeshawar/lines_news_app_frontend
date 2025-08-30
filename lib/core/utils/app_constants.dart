// lib/core/utils/app_constants.dart
import 'package:flutter/foundation.dart';

class AppConstants {
  // API Configuration - Use EnvironmentConfig for dynamic URLs
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  static const String languageKey = 'language_preference';
  static const String notificationKey = 'notification_settings';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // App Configuration
  static const String appName = 'Lines - The World in One Line';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@linesapp.com';
  
  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/linesapp';
  static const String twitterUrl = 'https://twitter.com/linesapp';
  static const String instagramUrl = 'https://instagram.com/linesapp';
  static const String linkedinUrl = 'https://linkedin.com/company/linesapp';
  
  // Privacy and Terms
  static const String privacyPolicyUrl = 'https://linesapp.com/privacy';
  static const String termsOfServiceUrl = 'https://linesapp.com/terms';
  static const String helpUrl = 'https://linesapp.com/help';
  
  // Feature Flags
  static const bool enableNotifications = true;
  static const bool enableDarkMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Ad Configuration
  static const int adRefreshInterval = 30; // seconds
  static const int maxAdsPerSession = 10;
  
  // Reading Configuration
  static const int wordsPerMinute = 200;
  static const int autoSaveInterval = 10; // seconds
  
  // Search Configuration
  static const int minSearchLength = 2;
  static const int maxRecentSearches = 10;
  static const int searchSuggestionLimit = 5;
  
  // Cache Configuration
  static const Duration imageCacheTime = Duration(days: 7);
  static const Duration articleCacheTime = Duration(hours: 1);
  static const Duration categoryCacheTime = Duration(hours: 6);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 100;
  static const int maxBioLength = 500;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedMessage = 'Session expired. Please login again.';
  static const String notFoundMessage = 'Requested resource not found.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registerSuccessMessage = 'Registration successful!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String passwordChangeSuccessMessage = 'Password changed successfully!';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Debounce Durations
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const Duration scrollDebounceDelay = Duration(milliseconds: 100);
  
  // Notification Types
  static const String articlePublishedNotification = 'article_published';
  static const String articleLikedNotification = 'article_liked';
  static const String followNotification = 'user_followed';
  static const String systemNotification = 'system_announcement';
  
  // Analytics Events
  static const String articleViewEvent = 'article_view';
  static const String articleShareEvent = 'article_share';
  static const String articleLikeEvent = 'article_like';
  static const String searchEvent = 'search_performed';
  static const String categoryViewEvent = 'category_view';
  static const String adClickEvent = 'ad_click';
  
  // Device Info
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  static const String platformWeb = 'web';
  static const String platformWindows = 'windows';
  static const String platformMacOS = 'macos';
  static const String platformLinux = 'linux';
}

// Environment Configuration
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment currentEnvironment = Environment.development;
  
  static String get baseUrl {
    // For web development with CORS issues, you can temporarily use relative URLs
    // if you set up a proxy, or use the absolute URL if CORS is properly configured
    if (kIsWeb && currentEnvironment == Environment.development) {
      // Option 1: Use relative URL with proxy configuration
      // return '/api';
      
      // Option 2: Use absolute URL (requires CORS configuration on backend)
      return 'http://localhost:3000/api';
      
      // Option 3: Use a development proxy server
      // return 'http://localhost:8080/api';
    }
    
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.linesapp.com';
      case Environment.production:
        return 'https://api.linesapp.com';
    }
  }
  
  static bool get isDebugMode {
    return currentEnvironment != Environment.production;
  }
  
  static bool get enableLogging {
    return currentEnvironment != Environment.production;
  }
  
  static String get sentryDsn {
    switch (currentEnvironment) {
      case Environment.development:
        return '';
      case Environment.staging:
        return 'your-staging-sentry-dsn';
      case Environment.production:
        return 'your-production-sentry-dsn';
    }
  }
  
  static String get googleAnalyticsId {
    switch (currentEnvironment) {
      case Environment.development:
        return '';
      case Environment.staging:
        return 'your-staging-ga-id';
      case Environment.production:
        return 'your-production-ga-id';
    }
  }
  
  // CORS Configuration for development
  static Map<String, String> get corsHeaders {
    if (currentEnvironment == Environment.development) {
      return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
        'Access-Control-Allow-Credentials': 'true',
      };
    }
    return {};
  }
  
  // Development proxy configuration
  static bool get useProxy {
    return kIsWeb && currentEnvironment == Environment.development;
  }
  
  static String get proxyTarget {
    return 'http://localhost:3000';
  }
}

// Feature Flags
class FeatureFlags {
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineReading = true;
  static const bool enableSocialSharing = true;
  static const bool enableComments = false; // Not yet implemented
  static const bool enableBookmarks = true;
  static const bool enableReadingProgress = true;
  static const bool enableAds = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDarkMode = true;
  static const bool enableMultiLanguage = false; // Future feature
  static const bool enableVoiceReading = false; // Future feature
  
  // Development-specific features
  static bool get enableMockData {
    return EnvironmentConfig.currentEnvironment == Environment.development;
  }
  
  static bool get enableApiLogging {
    return EnvironmentConfig.isDebugMode;
  }
  
  static bool get skipAuthentication {
    return false; // Set to true for UI testing without backend
  }
}

// Development Mock Data Configuration
class MockConfig {
  static bool get useMockData {
    return FeatureFlags.enableMockData && FeatureFlags.skipAuthentication;
  }
  
  static const String mockUserEmail = 'demo@linesapp.com';
  static const String mockUserPassword = 'demo123';
  static const String mockUserName = 'Demo User';
  static const String mockUserId = 'mock-user-id';
  
  static const Duration mockApiDelay = Duration(milliseconds: 500);
}