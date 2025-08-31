// lib/features/ai_ml/models/ai_news_model.dart
class AiNewsModel {
  final String id;
  final String headline;
  final String briefContent;
  final String? fullContent;
  final String category;
  final String? featuredImage;
  final List<String> tags;
  final String? sourceUrl;
  final String? companyMentioned;
  final String? technologyType;
  final int viewCount;
  final int shareCount;
  final double? relevanceScore;
  final DateTime publishedAt;
  final DateTime createdAt;
  final AiAuthor? author;
  final bool isTrending;
  final String? aiModel; // e.g., "GPT-4", "DALL-E", etc.
  final String? aiApplication; // e.g., "Chatbot", "Image Generation", etc.

  AiNewsModel({
    required this.id,
    required this.headline,
    required this.briefContent,
    this.fullContent,
    required this.category,
    this.featuredImage,
    required this.tags,
    this.sourceUrl,
    this.companyMentioned,
    this.technologyType,
    required this.viewCount,
    required this.shareCount,
    this.relevanceScore,
    required this.publishedAt,
    required this.createdAt,
    this.author,
    required this.isTrending,
    this.aiModel,
    this.aiApplication,
  });

  factory AiNewsModel.fromJson(Map<String, dynamic> json) {
    return AiNewsModel(
      id: json['id']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      briefContent: json['briefContent']?.toString() ?? '',
      fullContent: json['fullContent']?.toString(),
      category: json['category']?.toString() ?? 'AI',
      featuredImage: json['featuredImage']?.toString(),
      tags: _parseTags(json['tags']),
      sourceUrl: json['sourceUrl']?.toString(),
      companyMentioned: json['companyMentioned']?.toString(),
      technologyType: json['technologyType']?.toString(),
      viewCount: json['viewCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      relevanceScore: json['relevanceScore']?.toDouble(),
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      author: json['author'] != null ? AiAuthor.fromJson(json['author']) : null,
      isTrending: json['isTrending'] ?? false,
      aiModel: json['aiModel']?.toString(),
      aiApplication: json['aiApplication']?.toString(),
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
      'headline': headline,
      'briefContent': briefContent,
      'fullContent': fullContent,
      'category': category,
      'featuredImage': featuredImage,
      'tags': tags.join(', '),
      'sourceUrl': sourceUrl,
      'companyMentioned': companyMentioned,
      'technologyType': technologyType,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'relevanceScore': relevanceScore,
      'publishedAt': publishedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'author': author?.toJson(),
      'isTrending': isTrending,
      'aiModel': aiModel,
      'aiApplication': aiApplication,
    };
  }

  String get readingTime {
    final content = fullContent ?? briefContent;
    final wordCount = content.split(' ').length;
    final readingTimeMinutes = (wordCount / 200).ceil();
    return '$readingTimeMinutes min read';
  }
}

class AiAuthor {
  final String id;
  final String name;
  final String? company;
  final String? avatar;
  final String? expertise; // e.g., "AI Researcher", "ML Engineer"

  AiAuthor({
    required this.id,
    required this.name,
    this.company,
    this.avatar,
    this.expertise,
  });

  factory AiAuthor.fromJson(Map<String, dynamic> json) {
    return AiAuthor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString(),
      avatar: json['avatar']?.toString(),
      expertise: json['expertise']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'avatar': avatar,
      'expertise': expertise,
    };
  }
}

class AiCategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int articleCount;
  final bool isHot;

  AiCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.articleCount,
    required this.isHot,
  });

  factory AiCategoryModel.fromJson(Map<String, dynamic> json) {
    return AiCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      articleCount: json['articleCount'] ?? 0,
      isHot: json['isHot'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'articleCount': articleCount,
      'isHot': isHot,
    };
  }
}

class AiCategoryHelper {
  static List<AiCategoryModel> getDefaultCategories() {
    return [
      AiCategoryModel(
        id: '1',
        name: 'ChatGPT',
        description: 'Latest updates on ChatGPT',
        iconUrl: '',
        articleCount: 25,
        isHot: true,
      ),
      AiCategoryModel(
        id: '2',
        name: 'Machine Learning',
        description: 'ML algorithms and research',
        iconUrl: '',
        articleCount: 42,
        isHot: false,
      ),
      AiCategoryModel(
        id: '3',
        name: 'Deep Learning',
        description: 'Neural networks and deep learning',
        iconUrl: '',
        articleCount: 38,
        isHot: true,
      ),
      AiCategoryModel(
        id: '4',
        name: 'Computer Vision',
        description: 'Image and video AI',
        iconUrl: '',
        articleCount: 20,
        isHot: false,
      ),
      AiCategoryModel(
        id: '5',
        name: 'NLP',
        description: 'Natural Language Processing',
        iconUrl: '',
        articleCount: 35,
        isHot: true,
      ),
      AiCategoryModel(
        id: '6',
        name: 'Robotics',
        description: 'AI in robotics',
        iconUrl: '',
        articleCount: 18,
        isHot: false,
      ),
    ];
  }
}