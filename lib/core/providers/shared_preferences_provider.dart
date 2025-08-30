import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Helper class for managing shared preferences
class PreferencesHelper {
  final SharedPreferences _prefs;

  PreferencesHelper(this._prefs);

  // Theme preferences
  String get theme => _prefs.getString('theme') ?? 'light';
  Future<void> setTheme(String theme) => _prefs.setString('theme', theme);

  // Language preferences
  String get language => _prefs.getString('language') ?? 'en';
  Future<void> setLanguage(String language) => _prefs.setString('language', language);

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool('has_seen_onboarding') ?? false;
  Future<void> setHasSeenOnboarding(bool value) => _prefs.setBool('has_seen_onboarding', value);

  // Notification settings
  bool get pushNotificationsEnabled => _prefs.getBool('push_notifications') ?? true;
  Future<void> setPushNotificationsEnabled(bool value) => _prefs.setBool('push_notifications', value);

  bool get emailNotificationsEnabled => _prefs.getBool('email_notifications') ?? true;
  Future<void> setEmailNotificationsEnabled(bool value) => _prefs.setBool('email_notifications', value);

  // Reading preferences
  double get fontSize => _prefs.getDouble('font_size') ?? 16.0;
  Future<void> setFontSize(double size) => _prefs.setDouble('font_size', size);

  String get fontFamily => _prefs.getString('font_family') ?? 'Poppins';
  Future<void> setFontFamily(String family) => _prefs.setString('font_family', family);

  bool get nightModeEnabled => _prefs.getBool('night_mode') ?? false;
  Future<void> setNightModeEnabled(bool value) => _prefs.setBool('night_mode', value);

  // App settings
  bool get analyticsEnabled => _prefs.getBool('analytics_enabled') ?? true;
  Future<void> setAnalyticsEnabled(bool value) => _prefs.setBool('analytics_enabled', value);

  bool get crashReportingEnabled => _prefs.getBool('crash_reporting') ?? true;
  Future<void> setCrashReportingEnabled(bool value) => _prefs.setBool('crash_reporting', value);

  // Auto-save settings
  bool get autoSaveEnabled => _prefs.getBool('auto_save') ?? true;
  Future<void> setAutoSaveEnabled(bool value) => _prefs.setBool('auto_save', value);

  int get autoSaveInterval => _prefs.getInt('auto_save_interval') ?? 30; // seconds
  Future<void> setAutoSaveInterval(int interval) => _prefs.setInt('auto_save_interval', interval);

  // Search preferences
  List<String> get recentSearches => _prefs.getStringList('recent_searches') ?? [];
  Future<void> addRecentSearch(String search) async {
    final searches = recentSearches;
    searches.removeWhere((s) => s.toLowerCase() == search.toLowerCase());
    searches.insert(0, search);
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }
    await _prefs.setStringList('recent_searches', searches);
  }
  Future<void> clearRecentSearches() => _prefs.remove('recent_searches');

  // Cache settings
  bool get cacheImages => _prefs.getBool('cache_images') ?? true;
  Future<void> setCacheImages(bool value) => _prefs.setBool('cache_images', value);

  bool get cacheArticles => _prefs.getBool('cache_articles') ?? true;
  Future<void> setCacheArticles(bool value) => _prefs.setBool('cache_articles', value);

  // Data usage settings
  bool get downloadOnWifiOnly => _prefs.getBool('download_wifi_only') ?? false;
  Future<void> setDownloadOnWifiOnly(bool value) => _prefs.setBool('download_wifi_only', value);

  bool get preloadImages => _prefs.getBool('preload_images') ?? true;
  Future<void> setPreloadImages(bool value) => _prefs.setBool('preload_images', value);

  // App version and migration
  String get appVersion => _prefs.getString('app_version') ?? '1.0.0';
  Future<void> setAppVersion(String version) => _prefs.setString('app_version', version);

  int get dbVersion => _prefs.getInt('db_version') ?? 1;
  Future<void> setDbVersion(int version) => _prefs.setInt('db_version', version);

  // First time flags
  bool get isFirstLaunch => _prefs.getBool('first_launch') ?? true;
  Future<void> setIsFirstLaunch(bool value) => _prefs.setBool('first_launch', value);

  bool get hasRatedApp => _prefs.getBool('has_rated_app') ?? false;
  Future<void> setHasRatedApp(bool value) => _prefs.setBool('has_rated_app', value);

  // App usage statistics
  int get appLaunchCount => _prefs.getInt('app_launch_count') ?? 0;
  Future<void> incrementAppLaunchCount() async {
    await _prefs.setInt('app_launch_count', appLaunchCount + 1);
  }

  int get totalReadingTime => _prefs.getInt('total_reading_time') ?? 0; // in seconds
  Future<void> addReadingTime(int seconds) async {
    await _prefs.setInt('total_reading_time', totalReadingTime + seconds);
  }

  // Last sync timestamps
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getInt('last_sync_time');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  Future<void> setLastSyncTime(DateTime time) {
    return _prefs.setInt('last_sync_time', time.millisecondsSinceEpoch);
  }

  // User preferences backup
  Future<Map<String, dynamic>> exportPreferences() async {
    final keys = _prefs.getKeys();
    final Map<String, dynamic> preferences = {};
    
    for (final key in keys) {
      final value = _prefs.get(key);
      preferences[key] = value;
    }
    
    return preferences;
  }

  Future<void> importPreferences(Map<String, dynamic> preferences) async {
    for (final entry in preferences.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      }
    }
  }

  // Clear all preferences
  Future<void> clearAllPreferences() => _prefs.clear();
}

// Provider for PreferencesHelper
final preferencesHelperProvider = Provider<PreferencesHelper>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return PreferencesHelper(prefs);
});

// Individual preference providers
final themePreferenceProvider = StateProvider<String>((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return helper.theme;
});

final languagePreferenceProvider = StateProvider<String>((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return helper.language;
});

final fontSizePreferenceProvider = StateProvider<double>((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return helper.fontSize;
});

final nightModePreferenceProvider = StateProvider<bool>((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return helper.nightModeEnabled;
});

final pushNotificationsPreferenceProvider = StateProvider<bool>((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return helper.pushNotificationsEnabled;
});

// Actions for updating preferences
final preferencesActionsProvider = Provider((ref) {
  final helper = ref.read(preferencesHelperProvider);
  return PreferencesActions(helper, ref);
});

class PreferencesActions {
  final PreferencesHelper _helper;
  final Ref _ref;

  PreferencesActions(this._helper, this._ref);

  Future<void> updateTheme(String theme) async {
    await _helper.setTheme(theme);
    _ref.read(themePreferenceProvider.notifier).state = theme;
  }

  Future<void> updateLanguage(String language) async {
    await _helper.setLanguage(language);
    _ref.read(languagePreferenceProvider.notifier).state = language;
  }

  Future<void> updateFontSize(double fontSize) async {
    await _helper.setFontSize(fontSize);
    _ref.read(fontSizePreferenceProvider.notifier).state = fontSize;
  }

  Future<void> updateNightMode(bool enabled) async {
    await _helper.setNightModeEnabled(enabled);
    _ref.read(nightModePreferenceProvider.notifier).state = enabled;
  }

  Future<void> updatePushNotifications(bool enabled) async {
    await _helper.setPushNotificationsEnabled(enabled);
    _ref.read(pushNotificationsPreferenceProvider.notifier).state = enabled;
  }
}