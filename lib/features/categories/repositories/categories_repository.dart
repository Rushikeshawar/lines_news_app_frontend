// lib/features/categories/repositories/categories_repository.dart
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final ApiClient _apiClient;

  CategoriesRepository(this._apiClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final categoriesData = data['categories'] as List<dynamic>? ?? [];
          return categoriesData.map((categoryJson) => 
            CategoryModel.fromJson(categoryJson as Map<String, dynamic>)
          ).toList();
        }
      }
      
      // Fallback to default categories
      return CategoryHelper.getDefaultCategories();
    } catch (e) {
      print('Error in getCategories: $e');
      // Return default categories on error
      return CategoryHelper.getDefaultCategories();
    }
  }

  Future<List<CategoryModel>> getTrendingCategories({int limit = 5, String timeframe = '7d'}) async {
    try {
      final response = await _apiClient.get(
        '/categories/trending',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final categoriesData = data['categories'] as List<dynamic>? ?? [];
          return categoriesData.map((categoryJson) => 
            CategoryModel.fromJson(categoryJson as Map<String, dynamic>)
          ).toList();
        }
      }
      
      return CategoryHelper.getDefaultCategories().take(limit).toList();
    } catch (e) {
      print('Error in getTrendingCategories: $e');
      return CategoryHelper.getDefaultCategories().take(limit).toList();
    }
  }

  Future<Map<String, dynamic>> getCategoryStats(String category, {String timeframe = '30d'}) async {
    try {
      final response = await _apiClient.get(
        '/categories/$category/stats',
        queryParameters: {
          'timeframe': timeframe,
        },
      );
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['data'] ?? {};
      }
      
      return {};
    } catch (e) {
      print('Error in getCategoryStats: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> compareCategories(List<String> categories, {String timeframe = '30d'}) async {
    try {
      final response = await _apiClient.post(
        '/categories/compare',
        data: {
          'categories': categories,
          'timeframe': timeframe,
        },
      );
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['data'] ?? {};
      }
      
      return {};
    } catch (e) {
      print('Error in compareCategories: $e');
      return {};
    }
  }
}