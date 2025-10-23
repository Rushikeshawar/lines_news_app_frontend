// lib/features/time_saver/models/time_saver_model.dart

class TimeSaverContent {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String? imageUrl;
  final String? iconName;
  final String? bgColor;
  final List<String> keyPoints;
  final String? sourceUrl;
  final int readTimeSeconds;
  final int viewCount;
  final bool isPriority;
  final String contentType;
  final DateTime publishedAt;
  final String? tags;
  final String? contentGroup;
  
  // Linked article information
  final String? linkedArticleId;
  final String? linkedAiArticleId;
  final Map<String, dynamic>? linkedArticle;
  final Map<String, dynamic>? linkedAiArticle;

  TimeSaverContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    this.imageUrl,
    this.iconName,
    this.bgColor,
    required this.keyPoints,
    this.sourceUrl,
    required this.readTimeSeconds,
    required this.viewCount,
    required this.isPriority,
    required this.contentType,
    required this.publishedAt,
    this.tags,
    this.contentGroup,
    this.linkedArticleId,
    this.linkedAiArticleId,
    this.linkedArticle,
    this.linkedAiArticle,
  });

  factory TimeSaverContent.fromJson(Map<String, dynamic> json) {
    // Helper to parse keyPoints safely
    List<String> parseKeyPoints(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        if (value.isEmpty) return [];
        return value.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    // Helper to parse int safely
    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper to parse DateTime safely
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Helper to parse bool safely
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return false;
    }

    return TimeSaverContent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      iconName: json['iconName']?.toString(),
      bgColor: json['bgColor']?.toString(),
      keyPoints: parseKeyPoints(json['keyPoints']),
      sourceUrl: json['sourceUrl']?.toString(),
      readTimeSeconds: parseInt(json['readTimeSeconds'], 60),
      viewCount: parseInt(json['viewCount'], 0),
      isPriority: parseBool(json['isPriority']),
      contentType: json['contentType']?.toString() ?? 'DIGEST',
      publishedAt: parseDateTime(json['publishedAt']),
      tags: json['tags']?.toString(),
      contentGroup: json['contentGroup']?.toString(),
      linkedArticleId: json['linkedArticleId']?.toString(),
      linkedAiArticleId: json['linkedAiArticleId']?.toString(),
      linkedArticle: json['linkedArticle'] is Map 
          ? Map<String, dynamic>.from(json['linkedArticle']) 
          : null,
      linkedAiArticle: json['linkedAiArticle'] is Map 
          ? Map<String, dynamic>.from(json['linkedAiArticle']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'category': category,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'bgColor': bgColor,
      'keyPoints': keyPoints.join('|'),
      'sourceUrl': sourceUrl,
      'readTimeSeconds': readTimeSeconds,
      'viewCount': viewCount,
      'isPriority': isPriority,
      'contentType': contentType,
      'publishedAt': publishedAt.toIso8601String(),
      'tags': tags,
      'contentGroup': contentGroup,
      'linkedArticleId': linkedArticleId,
      'linkedAiArticleId': linkedAiArticleId,
      'linkedArticle': linkedArticle,
      'linkedAiArticle': linkedAiArticle,
    };
  }

  TimeSaverContent copyWith({
    String? id,
    String? title,
    String? summary,
    String? category,
    String? imageUrl,
    String? iconName,
    String? bgColor,
    List<String>? keyPoints,
    String? sourceUrl,
    int? readTimeSeconds,
    int? viewCount,
    bool? isPriority,
    String? contentType,
    DateTime? publishedAt,
    String? tags,
    String? contentGroup,
    String? linkedArticleId,
    String? linkedAiArticleId,
    Map<String, dynamic>? linkedArticle,
    Map<String, dynamic>? linkedAiArticle,
  }) {
    return TimeSaverContent(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      bgColor: bgColor ?? this.bgColor,
      keyPoints: keyPoints ?? this.keyPoints,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      readTimeSeconds: readTimeSeconds ?? this.readTimeSeconds,
      viewCount: viewCount ?? this.viewCount,
      isPriority: isPriority ?? this.isPriority,
      contentType: contentType ?? this.contentType,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      contentGroup: contentGroup ?? this.contentGroup,
      linkedArticleId: linkedArticleId ?? this.linkedArticleId,
      linkedAiArticleId: linkedAiArticleId ?? this.linkedAiArticleId,
      linkedArticle: linkedArticle ?? this.linkedArticle,
      linkedAiArticle: linkedAiArticle ?? this.linkedAiArticle,
    );
  }

  // Helper methods
  bool get hasLinkedArticle => linkedArticle != null || linkedAiArticle != null;
  
  String get linkedArticleSlug {
    if (linkedArticle != null && linkedArticle!['slug'] != null) {
      return linkedArticle!['slug'] as String;
    }
    return '';
  }

  String get linkedArticleHeadline {
    if (linkedArticle != null && linkedArticle!['headline'] != null) {
      return linkedArticle!['headline'] as String;
    }
    if (linkedAiArticle != null && linkedAiArticle!['headline'] != null) {
      return linkedAiArticle!['headline'] as String;
    }
    return '';
  }

  String get readTimeFormatted {
    final minutes = readTimeSeconds ~/ 60;
    if (minutes < 1) {
      return '< 1 min read';
    } else if (minutes == 1) {
      return '1 min read';
    } else {
      return '$minutes min read';
    }
  }
}

// Quick Stats Model
class QuickStats {
  final int totalContent;
  final int todayContent;
  final int weeklyContent;
  final int monthlyContent;
  final Map<String, int> categoryBreakdown;

  QuickStats({
    required this.totalContent,
    required this.todayContent,
    required this.weeklyContent,
    required this.monthlyContent,
    required this.categoryBreakdown,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    Map<String, int> parseCategoryBreakdown(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        final result = <String, int>{};
        value.forEach((key, val) {
          result[key.toString()] = parseInt(val, 0);
        });
        return result;
      }
      return {};
    }

    return QuickStats(
      totalContent: parseInt(json['totalContent'], 0),
      todayContent: parseInt(json['todayContent'], 0),
      weeklyContent: parseInt(json['weeklyContent'], 0),
      monthlyContent: parseInt(json['monthlyContent'], 0),
      categoryBreakdown: parseCategoryBreakdown(json['categoryBreakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalContent': totalContent,
      'todayContent': todayContent,
      'weeklyContent': weeklyContent,
      'monthlyContent': monthlyContent,
      'categoryBreakdown': categoryBreakdown,
    };
  }
}

// ContentType enum for type checking
enum ContentType {
  digest,
  highlights,
  quickUpdate,
  breaking,
}

// Extension to convert string to ContentType
extension ContentTypeExtension on String {
  ContentType get toContentType {
    switch (toUpperCase()) {
      case 'DIGEST':
        return ContentType.digest;
      case 'HIGHLIGHTS':
        return ContentType.highlights;
      case 'QUICK_UPDATE':
        return ContentType.quickUpdate;
      case 'BREAKING':
        return ContentType.breaking;
      default:
        return ContentType.digest;
    }
  }
}