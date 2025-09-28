// lib/features/auth/models/auth_models.dart - COMPLETE VERSION WITH USER AND USERROLE
import '../../articles/models/article_model.dart';

// ADD THIS: UserRole enum definition
enum UserRole {
  admin,
  editor,
  user,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.editor:
        return 'Editor';
      case UserRole.user:
        return 'User';
    }
  }
}

// ADD THIS: User class definition
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? fullName;
  final String? avatar;
  final UserRole role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.fullName,
    this.avatar,
    this.role = UserRole.user,
    this.isEmailVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['display_name'] as String?,
      fullName: json['fullName'] as String? ?? json['full_name'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['role'] as String?)?.toLowerCase(),
        orElse: () => UserRole.user,
      ),
      isEmailVerified: json['isEmailVerified'] as bool? ?? json['is_email_verified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'avatar': avatar,
      'role': role.name,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? fullName,
    String? avatar,
    UserRole? role,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }

  String get name => displayName ?? fullName ?? email.split('@').first;
  
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool hasRole(UserRole requiredRole) {
    switch (requiredRole) {
      case UserRole.admin:
        return role == UserRole.admin;
      case UserRole.editor:
        return role == UserRole.admin || role == UserRole.editor;
      case UserRole.user:
        return true;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, role: $role}';
  }
}

// Your existing classes below (keep all of these)

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