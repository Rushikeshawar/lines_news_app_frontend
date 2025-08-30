// lib/features/favorites/models/favorite_model.dart
import 'package:flutter/foundation.dart';

class UserFavorite {
  final String id;
  final String headline;
  final String briefContent;
  final String category;
  final int priorityLevel;
  final String? featuredImage;
  final List<String> tags;
  final String slug;
  final int viewCount;
  final int shareCount;
  final DateTime publishedAt;
  final Author? author;
  final DateTime savedAt;
  final bool isFavorite;

  UserFavorite({
    required this.id,
    required this.headline,
    required this.briefContent,
    required this.category,
    required this.priorityLevel,
    this.featuredImage,
    required this.tags,
    required this.slug,
    required this.viewCount,
    required this.shareCount,
    required this.publishedAt,
    this.author,
    required this.savedAt,
    required this.isFavorite,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    return UserFavorite(
      id: json['id']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      briefContent: json['briefContent']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priorityLevel: json['priorityLevel'] ?? 0,
      featuredImage: json['featuredImage']?.toString(),
      tags: _parseTags(json['tags']),
      slug: json['slug']?.toString() ?? '',
      viewCount: json['viewCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      publishedAt: _parseDateTime(json['publishedAt']),
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      savedAt: _parseDateTime(json['savedAt']),
      isFavorite: json['isFavorite'] ?? false,
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

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        debugPrint('Error parsing datetime: $dateTime');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headline': headline,
      'briefContent': briefContent,
      'category': category,
      'priorityLevel': priorityLevel,
      'featuredImage': featuredImage,
      'tags': tags.join(', '),
      'slug': slug,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author?.toJson(),
      'savedAt': savedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserFavorite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Author {
  final String id;
  final String fullName;
  final String? avatar;

  Author({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'avatar': avatar,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Author && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
