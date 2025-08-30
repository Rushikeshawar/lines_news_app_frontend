// lib/features/articles/models/article_model.dart
class Article {
  final String id;
  final String headline;
  final String? briefContent;
  final String? fullContent;
  final NewsCategory category;
  final ArticleStatus status;
  final int priorityLevel;
  final String authorId;
  final String? approvedBy;
  final String? featuredImage;
  final String? tags;
  final String? slug;
  final String? metaTitle;
  final String? metaDescription;
  final int viewCount;
  final int shareCount;
  final DateTime? publishedAt;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author;
  final User? approver;
  final bool? isFavorited;
  final DateTime? savedAt; // Added for favorites

  Article({
    required this.id,
    required this.headline,
    this.briefContent,
    this.fullContent,
    required this.category,
    required this.status,
    required this.priorityLevel,
    required this.authorId,
    this.approvedBy,
    this.featuredImage,
    this.tags,
    this.slug,
    this.metaTitle,
    this.metaDescription,
    required this.viewCount,
    required this.shareCount,
    this.publishedAt,
    this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.approver,
    this.isFavorited,
    this.savedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      headline: json['headline'] ?? '',
      briefContent: json['brief_content'] ?? json['briefContent'],
      fullContent: json['full_content'] ?? json['fullContent'],
      category: NewsCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['category'] ?? 'GENERAL').toUpperCase(),
        orElse: () => NewsCategory.general,
      ),
      status: ArticleStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] ?? 'PUBLISHED').toUpperCase(),
        orElse: () => ArticleStatus.published,
      ),
      priorityLevel: json['priority_level'] ?? json['priorityLevel'] ?? 0,
      authorId: json['author_id'] ?? json['authorId'] ?? '',
      approvedBy: json['approved_by'] ?? json['approvedBy'],
      featuredImage: json['featured_image'] ?? json['featuredImage'],
      tags: json['tags'],
      slug: json['slug'],
      metaTitle: json['meta_title'] ?? json['metaTitle'],
      metaDescription: json['meta_description'] ?? json['metaDescription'],
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      shareCount: json['share_count'] ?? json['shareCount'] ?? 0,
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at']) : 
                   json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : 
                   json['scheduledAt'] != null ? DateTime.tryParse(json['scheduledAt']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
      isFavorited: json['is_favorited'] ?? json['isFavorite'],
      savedAt: json['saved_at'] != null ? DateTime.tryParse(json['saved_at']) : 
               json['savedAt'] != null ? DateTime.tryParse(json['savedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headline': headline,
      'brief_content': briefContent,
      'full_content': fullContent,
      'category': category.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'priority_level': priorityLevel,
      'author_id': authorId,
      'approved_by': approvedBy,
      'featured_image': featuredImage,
      'tags': tags,
      'slug': slug,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'view_count': viewCount,
      'share_count': shareCount,
      'published_at': publishedAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorited': isFavorited,
      'saved_at': savedAt?.toIso8601String(),
    };
  }

  List<String> get tagsList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  String get readingTime {
    if (fullContent == null) return '1 min read';
    final wordCount = fullContent!.split(' ').length;
    final readingTimeMinutes = (wordCount / 200).ceil();
    return '$readingTimeMinutes min read';
  }

  String get categoryDisplayName {
    return category.name.toLowerCase().replaceAll('_', ' ').split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class User {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final bool isActive;
  final String? avatar;
  final Map<String, dynamic>? preferences;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.isActive,
    this.avatar,
    this.preferences,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'],
      role: UserRole.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['role'] ?? 'USER').toUpperCase(),
        orElse: () => UserRole.user,
      ),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      avatar: json['avatar'],
      preferences: json['preferences'] as Map<String, dynamic>?,
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login']) : 
                 json['lastLogin'] != null ? DateTime.tryParse(json['lastLogin']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name.toUpperCase(),
      'is_active': isActive,
      'avatar': avatar,
      'preferences': preferences,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => fullName ?? email.split('@').first;
}

class Advertisement {
  final String id;
  final String title;
  final String? content;
  final String? imageUrl;
  final String? targetUrl;
  final AdPosition position;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final double? budget;
  final int clickCount;
  final int impressions;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
    required this.id,
    required this.title,
    this.content,
    this.imageUrl,
    this.targetUrl,
    required this.position,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.budget,
    required this.clickCount,
    required this.impressions,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      targetUrl: json['target_url'] ?? json['targetUrl'],
      position: AdPosition.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['position'] ?? 'BANNER').toUpperCase(),
        orElse: () => AdPosition.banner,
      ),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      startDate: DateTime.tryParse(json['start_date'] ?? json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? json['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      budget: json['budget']?.toDouble(),
      clickCount: json['click_count'] ?? json['clickCount'] ?? 0,
      impressions: json['impressions'] ?? 0,
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'position': position.name.toUpperCase(),
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'click_count': clickCount,
      'impressions': impressions,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

class UserFavorite {
  final String userId;
  final String newsId;
  final DateTime savedAt;
  final Article? article;

  UserFavorite({
    required this.userId,
    required this.newsId,
    required this.savedAt,
    this.article,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    // Handle the case where the API returns the article data directly
    // with savedAt and isFavorite fields added to the article object
    if (json.containsKey('savedAt') && json.containsKey('id')) {
      // This is an article with favorite metadata
      final article = Article.fromJson(json);
      return UserFavorite(
        userId: '', // Not provided in this format
        newsId: json['id'] ?? '',
        savedAt: DateTime.tryParse(json['savedAt'] ?? '') ?? DateTime.now(),
        article: article,
      );
    } else {
      // This is the expected UserFavorite format
      return UserFavorite(
        userId: json['user_id'] ?? json['userId'] ?? '',
        newsId: json['news_id'] ?? json['newsId'] ?? json['id'] ?? '',
        savedAt: DateTime.tryParse(json['saved_at'] ?? json['savedAt'] ?? '') ?? DateTime.now(),
        article: json['article'] != null ? Article.fromJson(json['article']) : null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'news_id': newsId,
      'saved_at': savedAt.toIso8601String(),
      'article': article?.toJson(),
    };
  }
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] ?? 'SYSTEM_ANNOUNCEMENT').toUpperCase(),
        orElse: () => NotificationType.systemAnnouncement,
      ),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : 
              json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name.toUpperCase(),
      'title': title,
      'message': message,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Enums
enum UserRole {
  user,
  editor,
  adManager,
  admin,
}

enum NewsCategory {
  general,
  national,
  international,
  politics,
  business,
  technology,
  science,
  health,
  education,
  environment,
  sports,
  entertainment,
  crime,
  lifestyle,
  finance,
  food,
  fashion,
  others,
}

enum ArticleStatus {
  draft,
  pending,
  approved,
  rejected,
  published,
  archived,
}

enum AdPosition {
  banner,
  sidebar,
  inline,
  popup,
  interstitial,
}

enum NotificationType {
  articleApproved,
  articleRejected,
  articlePublished,
  articleChangesRequested,
  systemAnnouncement,
  accountUpdate,
  promotional,
  securityAlert,
}