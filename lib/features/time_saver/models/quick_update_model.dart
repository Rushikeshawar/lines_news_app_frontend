// lib/features/time_saver/models/quick_update_model.dart

class QuickUpdateModel {
  final String id;
  final String title;
  final String summary;
  final String? brief;  // Added
  final DateTime publishedAt;
  final DateTime timestamp;  // Added
  final int readTimeSeconds;
  final String? imageUrl;
  final String category;
  final int viewCount;
  final bool isHot;  // Added

  QuickUpdateModel({
    required this.id,
    required this.title,
    required this.summary,
    this.brief,
    required this.publishedAt,
    DateTime? timestamp,
    required this.readTimeSeconds,
    this.imageUrl,
    required this.category,
    this.viewCount = 0,
    this.isHot = false,
  }) : timestamp = timestamp ?? publishedAt;

  factory QuickUpdateModel.fromJson(Map<String, dynamic> json) {
    return QuickUpdateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      brief: json['brief'] as String? ?? json['summary'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.parse(json['publishedAt'] as String),
      readTimeSeconds: json['readTimeSeconds'] as int? ?? 60,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'GENERAL',
      viewCount: json['viewCount'] as int? ?? 0,
      isHot: json['isHot'] as bool? ?? json['isPriority'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'brief': brief,
      'publishedAt': publishedAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'readTimeSeconds': readTimeSeconds,
      'imageUrl': imageUrl,
      'category': category,
      'viewCount': viewCount,
      'isHot': isHot,
    };
  }

  QuickUpdateModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? brief,
    DateTime? publishedAt,
    DateTime? timestamp,
    int? readTimeSeconds,
    String? imageUrl,
    String? category,
    int? viewCount,
    bool? isHot,
  }) {
    return QuickUpdateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      brief: brief ?? this.brief,
      publishedAt: publishedAt ?? this.publishedAt,
      timestamp: timestamp ?? this.timestamp,
      readTimeSeconds: readTimeSeconds ?? this.readTimeSeconds,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      isHot: isHot ?? this.isHot,
    );
  }

  String get readTimeFormatted {
    final minutes = readTimeSeconds ~/ 60;
    if (minutes < 1) {
      return '< 1 min';
    } else if (minutes == 1) {
      return '1 min';
    } else {
      return '$minutes min';
    }
  }
}