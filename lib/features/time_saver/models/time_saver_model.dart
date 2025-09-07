// lib/features/time_saver/models/time_saver_model.dart
import 'package:flutter/material.dart';

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
  final String? contentGroup;
  final List<String> tags;

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
    this.contentGroup,
    this.tags = const [],
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
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['publishedAt'] ?? '') ?? DateTime.now(),
      isPriority: json['isPriority'] ?? false,
      contentType: ContentType.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['contentType'] ?? 'digest').toLowerCase(),
        orElse: () => ContentType.digest,
      ),
      contentGroup: json['contentGroup']?.toString(),
      tags: _parseTags(json['tags']),
    );
  }

  static List<String> _parseKeyPoints(dynamic keyPoints) {
    if (keyPoints == null) return [];
    if (keyPoints is String) {
      if (keyPoints.contains(',')) {
        return keyPoints.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } else if (keyPoints.contains('|')) {
        return keyPoints.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } else {
        return [keyPoints.trim()].where((e) => e.isNotEmpty).toList();
      }
    }
    if (keyPoints is List) {
      return keyPoints.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
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

  String get readTimeFormatted {
    if (readTimeSeconds < 60) {
      return '${readTimeSeconds}s';
    } else {
      final minutes = (readTimeSeconds / 60).round();
      return '${minutes}m';
    }
  }

  // Helper methods for content categorization
  bool get isTodayNew => DateTime.now().difference(publishedAt).inDays == 0;
  bool get isBreakingCritical => isPriority || contentType == ContentType.digest;
  bool get isWeeklyHighlight => DateTime.now().difference(publishedAt).inDays <= 7 && contentType == ContentType.highlights;
  bool get isMonthlyTop => DateTime.now().difference(publishedAt).inDays <= 30;
  bool get isBriefUpdate => contentType == ContentType.quickUpdate || readTimeSeconds <= 60;
  bool get isViralBuzz => viewCount > 1000 || tags.any((tag) => tag.toLowerCase().contains('viral') || tag.toLowerCase().contains('trending'));
  bool get isChangingNorms => category.toLowerCase().contains('society') || category.toLowerCase().contains('culture') || tags.any((tag) => tag.toLowerCase().contains('social'));
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
  final String? contentGroup;

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
    this.contentGroup,
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
      contentGroup: json['contentGroup']?.toString(),
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
  final String? contentGroup;

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
    this.contentGroup,
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
      contentGroup: json['contentGroup']?.toString(),
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
}

class QuickStats {
  final int storiesCount;
  final int updatesCount;
  final int breakingCount;
  final DateTime lastUpdated;
  final int todayNewCount;
  final int criticalCount;
  final int weeklyCount;
  final int monthlyCount;
  final int viralBuzzCount;
  final int changingNormsCount;

  QuickStats({
    required this.storiesCount,
    required this.updatesCount,
    required this.breakingCount,
    required this.lastUpdated,
    this.todayNewCount = 0,
    this.criticalCount = 0,
    this.weeklyCount = 0,
    this.monthlyCount = 0,
    this.viralBuzzCount = 0,
    this.changingNormsCount = 0,
  });

  factory QuickStats.fromJson(Map<String, dynamic> json) {
    return QuickStats(
      storiesCount: json['storiesCount'] ?? 0,
      updatesCount: json['updatesCount'] ?? 0,
      breakingCount: json['breakingCount'] ?? 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      todayNewCount: json['todayNewCount'] ?? 5,
      criticalCount: json['criticalCount'] ?? 7,
      weeklyCount: json['weeklyCount'] ?? 15,
      monthlyCount: json['monthlyCount'] ?? 30,
      viralBuzzCount: json['viralBuzzCount'] ?? 10,
      changingNormsCount: json['changingNormsCount'] ?? 10,
    );
  }
}

// Enums
enum ContentType {
  digest,
  quickUpdate,
  briefing,
  summary,
  highlights,
  viral,
  social,
  breaking,
}

enum BreakingPriority {
  low,
  medium,
  high,
  critical,
}