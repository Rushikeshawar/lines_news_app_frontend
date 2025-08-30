// lib/features/auth/models/auth_models.dart - SIMPLIFIED VERSION
import '../../articles/models/article_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final UserRole role;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = UserRole.user,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['full_name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['role'] ?? 'user').toLowerCase(),
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role.name.toUpperCase(),
    };
  }
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['current_password'] ?? json['currentPassword'] ?? '',
      newPassword: json['new_password'] ?? json['newPassword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}

class UpdateProfileRequest {
  final String? fullName;
  final String? avatar;
  final Map<String, dynamic>? preferences;

  UpdateProfileRequest({
    this.fullName,
    this.avatar,
    this.preferences,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      fullName: json['full_name'],
      avatar: json['avatar'],
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (avatar != null) data['avatar'] = avatar;
    if (preferences != null) data['preferences'] = preferences;
    return data;
  }
}

class UserStats {
  final int totalArticlesRead;
  final int totalReadingTime;
  final int favoriteArticles;
  final int articlesShared;
  final int readingStreak;
  final List<String> favoriteCategories;
  final Map<String, dynamic>? readingGoals;

  UserStats({
    required this.totalArticlesRead,
    required this.totalReadingTime,
    required this.favoriteArticles,
    required this.articlesShared,
    required this.readingStreak,
    required this.favoriteCategories,
    this.readingGoals,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalArticlesRead: json['total_articles_read'] ?? 0,
      totalReadingTime: json['total_reading_time'] ?? 0,
      favoriteArticles: json['favorite_articles'] ?? 0,
      articlesShared: json['articles_shared'] ?? 0,
      readingStreak: json['reading_streak'] ?? 0,
      favoriteCategories: List<String>.from(json['favorite_categories'] ?? []),
      readingGoals: json['reading_goals'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_articles_read': totalArticlesRead,
      'total_reading_time': totalReadingTime,
      'favorite_articles': favoriteArticles,
      'articles_shared': articlesShared,
      'reading_streak': readingStreak,
      'favorite_categories': favoriteCategories,
      'reading_goals': readingGoals,
    };
  }
}

class UserDashboard {
  final User user;
  final UserStats stats;
  final List<Article> recentArticles;
  final List<Article> recommendedArticles;
  final List<ReadingHistoryItem> readingHistory;
  final int unreadNotifications;

  UserDashboard({
    required this.user,
    required this.stats,
    required this.recentArticles,
    required this.recommendedArticles,
    required this.readingHistory,
    required this.unreadNotifications,
  });

  factory UserDashboard.fromJson(Map<String, dynamic> json) {
    return UserDashboard(
      user: User.fromJson(json['user'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      recentArticles: (json['recent_articles'] as List<dynamic>? ?? [])
          .map((item) => Article.fromJson(item))
          .toList(),
      recommendedArticles: (json['recommended_articles'] as List<dynamic>? ?? [])
          .map((item) => Article.fromJson(item))
          .toList(),
      readingHistory: (json['reading_history'] as List<dynamic>? ?? [])
          .map((item) => ReadingHistoryItem.fromJson(item))
          .toList(),
      unreadNotifications: json['unread_notifications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'stats': stats.toJson(),
      'recent_articles': recentArticles.map((article) => article.toJson()).toList(),
      'recommended_articles': recommendedArticles.map((article) => article.toJson()).toList(),
      'reading_history': readingHistory.map((item) => item.toJson()).toList(),
      'unread_notifications': unreadNotifications,
    };
  }
}

class ReadingHistoryItem {
  final String id;
  final String userId;
  final String articleId;
  final int? timeSpent;
  final double readProgress;
  final int? lastPosition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Article? article;

  ReadingHistoryItem({
    required this.id,
    required this.userId,
    required this.articleId,
    this.timeSpent,
    required this.readProgress,
    this.lastPosition,
    required this.createdAt,
    required this.updatedAt,
    this.article,
  });

  factory ReadingHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      articleId: json['article_id'] ?? '',
      timeSpent: json['time_spent'],
      readProgress: (json['read_progress'] ?? 0.0).toDouble(),
      lastPosition: json['last_position'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      article: json['article'] != null ? Article.fromJson(json['article']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'article_id': articleId,
      'time_spent': timeSpent,
      'read_progress': readProgress,
      'last_position': lastPosition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'article': article?.toJson(),
    };
  }

  String get formattedReadingTime {
    if (timeSpent == null) return '0m';
    
    final minutes = (timeSpent! / 60).floor();
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  String get progressPercentage {
    return '${(readProgress * 100).toInt()}%';
  }
}