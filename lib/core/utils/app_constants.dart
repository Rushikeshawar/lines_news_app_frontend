// lib/core/utils/app_constants.dart
class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const String websocketUrl = 'ws://localhost:3000';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // App Configuration
  static const String appName = 'Lines News';
  static const String appVersion = '1.0.0';
  static const int apiVersion = 1;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const Duration cacheTimeout = Duration(minutes: 15);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // App Limits
  static const int maxSearchHistory = 10;
  static const int maxFavorites = 1000;
  static const int maxNotifications = 100;
  
  // Demo Credentials
  static const String demoEmail = 'demo@example.com';
  static const String demoPassword = 'demo123';
  
  // Image Configuration
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImageSizeKB = 5120; // 5MB
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server error. Please try again later';
  static const String authErrorMessage = 'Authentication failed. Please login again';
  static const String genericErrorMessage = 'Something went wrong. Please try again';
  
  // Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  
  // URL Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'light';
  static const double defaultFontSize = 16.0;
  static const String defaultFontFamily = 'Poppins';
}