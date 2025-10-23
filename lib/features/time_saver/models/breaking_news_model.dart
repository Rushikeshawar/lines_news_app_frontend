// lib/features/time_saver/models/breaking_news_model.dart

enum BreakingPriority {
  critical,
  high,
  medium,
  low,
}

class BreakingNewsModel {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String? brief;  // Added
  final BreakingPriority priority;
  final DateTime publishedAt;
  final DateTime timestamp;  // Added
  final String? imageUrl;
  final String category;
  final int viewCount;
  final String? sourceUrl;
  final String? location;  // Added
  final List<String> tags;

  BreakingNewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    this.brief,
    required this.priority,
    required this.publishedAt,
    DateTime? timestamp,
    this.imageUrl,
    required this.category,
    this.viewCount = 0,
    this.sourceUrl,
    this.location,
    this.tags = const [],
  }) : timestamp = timestamp ?? publishedAt;

  factory BreakingNewsModel.fromJson(Map<String, dynamic> json) {
    return BreakingNewsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? json['summary'] as String,
      summary: json['summary'] as String? ?? '',
      brief: json['brief'] as String?,
      priority: _parsePriority(json['priority'] as String?),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'GENERAL',
      viewCount: json['viewCount'] as int? ?? 0,
      sourceUrl: json['sourceUrl'] as String?,
      location: json['location'] as String?,
      tags: json['tags'] != null 
          ? (json['tags'] is String 
              ? (json['tags'] as String).split(',').map((e) => e.trim()).toList()
              : List<String>.from(json['tags']))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'brief': brief,
      'priority': priority.name.toUpperCase(),
      'publishedAt': publishedAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
      'viewCount': viewCount,
      'sourceUrl': sourceUrl,
      'location': location,
      'tags': tags.join(','),
    };
  }

  static BreakingPriority _parsePriority(String? priority) {
    if (priority == null) return BreakingPriority.medium;
    
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return BreakingPriority.critical;
      case 'HIGH':
        return BreakingPriority.high;
      case 'MEDIUM':
        return BreakingPriority.medium;
      case 'LOW':
        return BreakingPriority.low;
      default:
        return BreakingPriority.medium;
    }
  }

  BreakingNewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? brief,
    BreakingPriority? priority,
    DateTime? publishedAt,
    DateTime? timestamp,
    String? imageUrl,
    String? category,
    int? viewCount,
    String? sourceUrl,
    String? location,
    List<String>? tags,
  }) {
    return BreakingNewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      brief: brief ?? this.brief,
      priority: priority ?? this.priority,
      publishedAt: publishedAt ?? this.publishedAt,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      location: location ?? this.location,
      tags: tags ?? this.tags,
    );
  }

  // Helper getters
  String get priorityLabel {
    switch (priority) {
      case BreakingPriority.critical:
        return 'CRITICAL';
      case BreakingPriority.high:
        return 'HIGH';
      case BreakingPriority.medium:
        return 'MEDIUM';
      case BreakingPriority.low:
        return 'LOW';
    }
  }
}