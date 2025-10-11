// lib/features/categories/repositories/categories_repository.dart
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final ApiClient _apiClient;

  CategoriesRepository(this._apiClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      
      print('Categories API Response: ${response.data}');
      
      // Backend returns: { success: true, data: { categories: [...], totalCategories: 18 } }
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          final categoriesData = data['categories'] as List<dynamic>? ?? [];
          
          final categories = categoriesData
              .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
          
          print('Parsed ${categories.length} categories');
          return categories;
        }
      }
      
      print('Failed to parse categories, using defaults');
      return CategoryHelper.getDefaultCategories();
    } catch (e) {
      print('Error in getCategories: $e');
      return CategoryHelper.getDefaultCategories();
    }
  }

  Future<List<CategoryModel>> getTrendingCategories({
    int limit = 5,
    String timeframe = '7d',
  }) async {
    try {
      final response = await _apiClient.get(
        '/categories/trending',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );
      
      // Backend returns: { success: true, data: { trending: [...] } }
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          final trendingData = data['trending'] as List<dynamic>? ?? [];
          
          return trendingData
              .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      return CategoryHelper.getDefaultCategories().take(limit).toList();
    } catch (e) {
      print('Error in getTrendingCategories: $e');
      return CategoryHelper.getDefaultCategories().take(limit).toList();
    }
  }

  Future<Map<String, dynamic>> getCategoryStats(
    String category, {
    String timeframe = '30d',
  }) async {
    try {
      final response = await _apiClient.get(
        '/categories/${category.toUpperCase()}/stats',
        queryParameters: {'timeframe': timeframe},
      );
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data['stats'] as Map<String, dynamic>? ?? {};
        }
      }
      
      return {};
    } catch (e) {
      print('Error in getCategoryStats: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> compareCategories(
    List<String> categories, {
    String timeframe = '30d',
  }) async {
    try {
      final response = await _apiClient.post(
        '/categories/compare',
        data: {
          'categories': categories.map((c) => c.toUpperCase()).toList(),
          'timeframe': timeframe,
        },
      );
      
      if (response.data is Map<String, dynamic>) {
        return response.data['data'] as Map<String, dynamic>? ?? {};
      }
      
      return {};
    } catch (e) {
      print('Error in compareCategories: $e');
      return {};
    }
  }
}