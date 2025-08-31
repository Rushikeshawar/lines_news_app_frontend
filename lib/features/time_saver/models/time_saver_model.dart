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
  final DateTime publishedAt;
  final DateTime createdAt;
  final bool isPriority;
  final ContentType contentType;

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
    required this.publishedAt,
    required this.createdAt,
    required this.isPriority,
    required this.contentType,
  });

  factory TimeSaverContent.fromJson(Map<String, dynamic> json) {
    return TimeSaverContent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      iconName: json['iconName']?.toString(),
      bgColor: json['bgColor']?.toString(),
      keyPoints: _parseKeyPoints(json['keyPoints']),
      sourceUrl: json['sourceUrl']?.toString(),
      readTimeSeconds: json['readTimeSeconds'] ?? 30,
      viewCount: json['viewCount'] ?? 0,
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isPriority: json['isPriority'] ?? false,
      contentType: ContentType.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['contentType'] ?? 'digest').toLowerCase(),
        orElse: () => ContentType.digest,
      ),
    );
  }

  static List<String> _parseKeyPoints(dynamic keyPoints) {
    if (keyPoints == null) return [];
    if (keyPoints is String) {
      return keyPoints.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (keyPoints is List) {
      return keyPoints.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
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
      'publishedAt': publishedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isPriority': isPriority,
      'contentType': contentType.name,
    };
  }

  String get readTimeFormatted {
    if (readTimeSeconds < 60) {
      return '${readTimeSeconds}s';
    } else {
      final minutes = (readTimeSeconds / 60).round();
      return '${minutes}m';
    }
  }
}

class QuickUpdateModel {
  final String id;
  final String title;
  final String brief;
  final String category;
  final String? imageUrl;
  final String? iconName;
  final List<String> tags;
  final DateTime timestamp;
  final bool isHot;
  final int engagementScore;

  QuickUpdateModel({
    required this.id,
    required this.title,
    required this.brief,
    required this.category,
    this.imageUrl,
    this.iconName,
    required this.tags,
    required this.timestamp,
    required this.isHot,
    required this.engagementScore,
  });

  factory QuickUpdateModel.fromJson(Map<String, dynamic> json) {
    return QuickUpdateModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      brief: json['brief']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      iconName: json['iconName']?.toString(),
      tags: _parseTags(json['tags']),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isHot: json['isHot'] ?? false,
      engagementScore: json['engagementScore'] ?? 0,
    );
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is String) {
      return tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (tags is List) {
      return tags.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brief': brief,
      'category': category,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'tags': tags.join(','),
      'timestamp': timestamp.toIso8601String(),
      'isHot': isHot,
      'engagementScore': engagementScore,
    };
  }
}

class BreakingNewsModel {
  final String id;
  final String title;
  final String brief;
  final String? imageUrl;
  final String? sourceUrl;
  final DateTime timestamp;
  final BreakingPriority priority;
  final String? location;
  final List<String> tags;

  BreakingNewsModel({
    required this.id,
    required this.title,
    required this.brief,
    this.imageUrl,
    this.sourceUrl,
    required this.timestamp,
    required this.priority,
    this.location,
    required this.tags,
  });

  factory BreakingNewsModel.fromJson(Map<String, dynamic> json) {
    return BreakingNewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      brief: json['brief']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      sourceUrl: json['sourceUrl']?.toString(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      priority: BreakingPriority.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['priority'] ?? 'medium').toLowerCase(),
        orElse: () => BreakingPriority.medium,
      ),
      location: json['location']?.toString(),
      tags: _parseTags(json['tags']),
    );
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is String) {
      return tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (tags is List) {
      return tags.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brief': brief,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.name,
      'location': location,
      'tags': tags.join(','),
    };
  }
}

class QuickStats {
  final int storiesCount;
  final int updatesCount;
  final int breakingCount;
  final DateTime lastUpdated;

  QuickStats({
    required this.storiesCount,
    required this.updatesCount,
    required this.breakingCount,
    required this.lastUpdated,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    return QuickStats(
      storiesCount: json['storiesCount'] ?? 0,
      updatesCount: json['updatesCount'] ?? 0,
      breakingCount: json['breakingCount'] ?? 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storiesCount': storiesCount,
      'updatesCount': updatesCount,
      'breakingCount': breakingCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// Enums
enum ContentType {
  digest,
  quickUpdate,
  briefing,
  summary,
  highlights,
}

enum BreakingPriority {
  low,
  medium,
  high,
  critical,
}