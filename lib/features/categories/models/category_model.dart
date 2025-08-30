// lib/features/categories/models/category_model.dart
import 'package:flutter/material.dart';
import '../../articles/models/article_model.dart';

class CategoryModel {
  final NewsCategory category;
  final String name;
  final IconData icon;
  final Color color;
  final int articleCount;

  CategoryModel({
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    this.articleCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryName = json['name'] as String? ?? 'General';
    final newsCategory = NewsCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => NewsCategory.general,
    );
    
    final defaultCategory = CategoryHelper.getCategoryModel(newsCategory);
    
    return CategoryModel(
      category: newsCategory,
      name: categoryName,
      icon: defaultCategory?.icon ?? Icons.article,
      color: defaultCategory?.color ?? Colors.blue,
      articleCount: json['articleCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'articleCount': articleCount,
    };
  }
}

class CategoryHelper {
  static List<CategoryModel> getDefaultCategories() {
    return [
      CategoryModel(category: NewsCategory.general, name: 'General', icon: Icons.article, color: Colors.blue),
      CategoryModel(category: NewsCategory.national, name: 'National', icon: Icons.flag, color: Colors.green),
      CategoryModel(category: NewsCategory.international, name: 'International', icon: Icons.public, color: Colors.orange),
      CategoryModel(category: NewsCategory.politics, name: 'Politics', icon: Icons.account_balance, color: Colors.red),
      CategoryModel(category: NewsCategory.business, name: 'Business', icon: Icons.business_center, color: Colors.indigo),
      CategoryModel(category: NewsCategory.technology, name: 'Technology', icon: Icons.computer, color: Colors.purple),
      CategoryModel(category: NewsCategory.science, name: 'Science', icon: Icons.science, color: Colors.cyan),
      CategoryModel(category: NewsCategory.health, name: 'Health', icon: Icons.health_and_safety, color: Colors.pink),
      CategoryModel(category: NewsCategory.education, name: 'Education', icon: Icons.school, color: Colors.brown),
      CategoryModel(category: NewsCategory.environment, name: 'Environment', icon: Icons.eco, color: Colors.green[700]!),
      CategoryModel(category: NewsCategory.sports, name: 'Sports', icon: Icons.sports, color: Colors.orange[700]!),
      CategoryModel(category: NewsCategory.entertainment, name: 'Entertainment', icon: Icons.movie, color: Colors.pink[400]!),
      CategoryModel(category: NewsCategory.crime, name: 'Crime', icon: Icons.security, color: Colors.red[800]!),
      CategoryModel(category: NewsCategory.lifestyle, name: 'Lifestyle', icon: Icons.style, color: Colors.purple[300]!),
      CategoryModel(category: NewsCategory.finance, name: 'Finance', icon: Icons.monetization_on, color: Colors.green[600]!),
      CategoryModel(category: NewsCategory.food, name: 'Food', icon: Icons.restaurant, color: Colors.amber),
      CategoryModel(category: NewsCategory.fashion, name: 'Fashion', icon: Icons.checkroom, color: Colors.pink[200]!),
    ];
  }
  
  static CategoryModel? getCategoryModel(NewsCategory category) {
    return getDefaultCategories().firstWhere(
      (model) => model.category == category,
      orElse: () => getDefaultCategories().first,
    );
  }
}