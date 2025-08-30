// lib/features/categories/providers/categories_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/categories_repository.dart';
import '../models/category_model.dart';

// Repository provider
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CategoriesRepository(apiClient);
});

// Main categories provider that fetches from API
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final repository = ref.read(categoriesRepositoryProvider);
    return await repository.getCategories();
  } catch (e) {
    print('Error fetching categories: $e');
    // Fallback to default categories
    return CategoryHelper.getDefaultCategories();
  }
});

// Trending categories provider
final trendingCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final repository = ref.read(categoriesRepositoryProvider);
    return await repository.getTrendingCategories();
  } catch (e) {
    print('Error fetching trending categories: $e');
    return CategoryHelper.getDefaultCategories().take(5).toList();
  }
});

// Category actions provider
final categoryActionsProvider = Provider<CategoryActions>((ref) {
  return CategoryActions(ref.read(categoriesRepositoryProvider));
});

class CategoryActions {
  final CategoriesRepository _repository;
  
  CategoryActions(this._repository);
  
  Future<Map<String, dynamic>> getCategoryStats(String categoryName, {String timeframe = '30d'}) async {
    try {
      return await _repository.getCategoryStats(categoryName, timeframe: timeframe);
    } catch (e) {
      print('Error getting category stats: $e');
      return {};
    }
  }
  
  Future<Map<String, dynamic>> compareCategories(List<String> categories, {String timeframe = '30d'}) async {
    try {
      return await _repository.compareCategories(categories, timeframe: timeframe);
    } catch (e) {
      print('Error comparing categories: $e');
      return {};
    }
  }
}