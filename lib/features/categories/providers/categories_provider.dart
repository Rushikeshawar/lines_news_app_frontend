// lib/features/categories/providers/categories_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/categories_repository.dart';
import '../models/category_model.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CategoriesRepository(apiClient);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final repository = ref.read(categoriesRepositoryProvider);
    final categories = await repository.getCategories();
    print('Categories provider loaded: ${categories.length} categories');
    return categories;
  } catch (e) {
    print('Error in categories provider: $e');
    return CategoryHelper.getDefaultCategories();
  }
});

final trendingCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final repository = ref.read(categoriesRepositoryProvider);
    return await repository.getTrendingCategories();
  } catch (e) {
    print('Error in trending categories provider: $e');
    return CategoryHelper.getDefaultCategories().take(5).toList();
  }
});

final categoryActionsProvider = Provider<CategoryActions>((ref) {
  return CategoryActions(ref.read(categoriesRepositoryProvider));
});

class CategoryActions {
  final CategoriesRepository _repository;
  
  CategoryActions(this._repository);
  
  Future<Map<String, dynamic>> getCategoryStats(
    String categoryName, {
    String timeframe = '30d',
  }) async {
    return await _repository.getCategoryStats(categoryName, timeframe: timeframe);
  }
  
  Future<Map<String, dynamic>> compareCategories(
    List<String> categories, {
    String timeframe = '30d',
  }) async {
    return await _repository.compareCategories(categories, timeframe: timeframe);
  }
}