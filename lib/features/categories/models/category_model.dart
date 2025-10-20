// lib/features/categories/models/category_model.dart
import 'package:flutter/material.dart';
import '../../articles/models/article_model.dart';

class CategoryModel {
  final String backendName; // ADDED: Store original backend name (e.g., "RUSHI", "TECHNOLOGY")
  final NewsCategory category; // Mapped enum
  final String name; // Display name
  final IconData icon;
  final Color color;
  final int articleCount;

  CategoryModel({
    required this.backendName, // ADDED
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    this.articleCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: { name: 'TECHNOLOGY', displayName: 'Technology', articleCount: 5 }
    final categoryName = (json['name'] as String? ?? 'GENERAL').toUpperCase();
    final displayName = json['displayName'] as String? ?? json['name'] ?? 'General';
    
    print('🔍 Parsing category from JSON:');
    print('   Raw name: ${json['name']}');
    print('   Uppercase name: $categoryName');
    print('   Display name: $displayName');
    print('   Article count: ${json['articleCount']}');
    
    // Try to find matching NewsCategory enum
    NewsCategory newsCategory;
    try {
      newsCategory = NewsCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == categoryName,
        orElse: () => NewsCategory.others,
      );
      print('   Mapped to enum: ${newsCategory.name}');
    } catch (e) {
      print('⚠️ Category not found in enum: $categoryName, using OTHERS');
      newsCategory = NewsCategory.others;
    }
    
    // Get default icon and color from helper
    final defaultCategory = CategoryHelper.getCategoryModel(newsCategory);
    
    // For custom categories (mapped to 'others'), use custom colors
    IconData finalIcon;
    Color finalColor;
    
    if (newsCategory == NewsCategory.others && categoryName != 'OTHERS') {
      // This is a custom category like RUSHI, RUSHIKESH AWARE, etc.
      finalIcon = CategoryHelper.getIconForCategory(categoryName);
      finalColor = CategoryHelper.getColorForCategory(categoryName);
      print('   Using custom icon/color for: $categoryName');
    } else {
      // Standard category
      finalIcon = defaultCategory?.icon ?? Icons.article;
      finalColor = defaultCategory?.color ?? Colors.blue;
    }
    
    return CategoryModel(
      backendName: categoryName, // Store original backend name
      category: newsCategory,
      name: displayName,
      icon: finalIcon,
      color: finalColor,
      articleCount: json['articleCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': backendName, // Use backend name, not enum name
      'displayName': name,
      'articleCount': articleCount,
    };
  }
  
  CategoryModel copyWith({
    String? backendName,
    NewsCategory? category,
    String? name,
    IconData? icon,
    Color? color,
    int? articleCount,
  }) {
    return CategoryModel(
      backendName: backendName ?? this.backendName,
      category: category ?? this.category,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      articleCount: articleCount ?? this.articleCount,
    );
  }
}

class CategoryHelper {
  static List<CategoryModel> getDefaultCategories() {
    return [];
  }
  
  static CategoryModel? getCategoryModel(NewsCategory category) {
    switch (category) {
      case NewsCategory.general:
        return CategoryModel(
          backendName: 'GENERAL',
          category: NewsCategory.general,
          name: 'General',
          icon: Icons.article,
          color: Colors.blue,
        );
      case NewsCategory.national:
        return CategoryModel(
          backendName: 'NATIONAL',
          category: NewsCategory.national,
          name: 'National',
          icon: Icons.flag,
          color: Colors.green,
        );
      case NewsCategory.international:
        return CategoryModel(
          backendName: 'INTERNATIONAL',
          category: NewsCategory.international,
          name: 'International',
          icon: Icons.public,
          color: Colors.orange,
        );
      case NewsCategory.politics:
        return CategoryModel(
          backendName: 'POLITICS',
          category: NewsCategory.politics,
          name: 'Politics',
          icon: Icons.account_balance,
          color: Colors.red,
        );
      case NewsCategory.business:
        return CategoryModel(
          backendName: 'BUSINESS',
          category: NewsCategory.business,
          name: 'Business',
          icon: Icons.business_center,
          color: Colors.indigo,
        );
      case NewsCategory.technology:
        return CategoryModel(
          backendName: 'TECHNOLOGY',
          category: NewsCategory.technology,
          name: 'Technology',
          icon: Icons.computer,
          color: Colors.purple,
        );
      case NewsCategory.science:
        return CategoryModel(
          backendName: 'SCIENCE',
          category: NewsCategory.science,
          name: 'Science',
          icon: Icons.science,
          color: Colors.cyan,
        );
      case NewsCategory.health:
        return CategoryModel(
          backendName: 'HEALTH',
          category: NewsCategory.health,
          name: 'Health',
          icon: Icons.health_and_safety,
          color: Colors.pink,
        );
      case NewsCategory.education:
        return CategoryModel(
          backendName: 'EDUCATION',
          category: NewsCategory.education,
          name: 'Education',
          icon: Icons.school,
          color: Colors.brown,
        );
      case NewsCategory.environment:
        return CategoryModel(
          backendName: 'ENVIRONMENT',
          category: NewsCategory.environment,
          name: 'Environment',
          icon: Icons.eco,
          color: Colors.green[700]!,
        );
      case NewsCategory.sports:
        return CategoryModel(
          backendName: 'SPORTS',
          category: NewsCategory.sports,
          name: 'Sports',
          icon: Icons.sports,
          color: Colors.orange[700]!,
        );
      case NewsCategory.entertainment:
        return CategoryModel(
          backendName: 'ENTERTAINMENT',
          category: NewsCategory.entertainment,
          name: 'Entertainment',
          icon: Icons.movie,
          color: Colors.pink[400]!,
        );
      case NewsCategory.crime:
        return CategoryModel(
          backendName: 'CRIME',
          category: NewsCategory.crime,
          name: 'Crime',
          icon: Icons.security,
          color: Colors.red[800]!,
        );
      case NewsCategory.lifestyle:
        return CategoryModel(
          backendName: 'LIFESTYLE',
          category: NewsCategory.lifestyle,
          name: 'Lifestyle',
          icon: Icons.style,
          color: Colors.purple[300]!,
        );
      case NewsCategory.finance:
        return CategoryModel(
          backendName: 'FINANCE',
          category: NewsCategory.finance,
          name: 'Finance',
          icon: Icons.monetization_on,
          color: Colors.green[600]!,
        );
      case NewsCategory.food:
        return CategoryModel(
          backendName: 'FOOD',
          category: NewsCategory.food,
          name: 'Food',
          icon: Icons.restaurant,
          color: Colors.amber,
        );
      case NewsCategory.fashion:
        return CategoryModel(
          backendName: 'FASHION',
          category: NewsCategory.fashion,
          name: 'Fashion',
          icon: Icons.checkroom,
          color: Colors.pink[200]!,
        );
      case NewsCategory.others:
        return CategoryModel(
          backendName: 'OTHERS',
          category: NewsCategory.others,
          name: 'Others',
          icon: Icons.more_horiz,
          color: Colors.grey,
        );
    }
  }
  
  // Helper to get icon for any category name (including custom ones)
  static IconData getIconForCategory(String categoryName) {
    final upperName = categoryName.toUpperCase();
    
    // Custom category icons based on name
    if (upperName.contains('RUSHI')) {
      return Icons.person; // Or any icon you prefer
    }
    if (upperName.contains('AWARE')) {
      return Icons.star;
    }
    
    // Default for unknown custom categories
    return Icons.category;
  }
  
  // Helper to get color for any category name (including custom ones)
  static Color getColorForCategory(String categoryName) {
    final upperName = categoryName.toUpperCase();
    
    // Try to match with enum first
    try {
      final category = NewsCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == upperName,
        orElse: () => NewsCategory.others,
      );
      if (category != NewsCategory.others) {
        return getCategoryModel(category)?.color ?? Colors.blue;
      }
    } catch (e) {
      // Continue to custom color logic
    }
    
    // Custom category - generate consistent color based on name
    final colors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.lime[700]!,
      Colors.cyan[700]!,
      Colors.pink[600]!,
      Colors.amber[700]!,
    ];
    
    // Use hash to get consistent color for same category name
    final index = categoryName.hashCode.abs() % colors.length;
    return colors[index];
  }
}