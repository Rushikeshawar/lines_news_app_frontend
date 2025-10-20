// lib/features/categories/providers/categories_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/categories_repository.dart';
import '../models/category_model.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CategoriesRepository(apiClient);
});

// FIXED: Don't use default categories as fallback - force using backend data
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    print('📂 Fetching categories from backend...');
    final repository = ref.read(categoriesRepositoryProvider);
    final categories = await repository.getCategories();
    
    print('✅ Categories loaded from backend: ${categories.length}');
    for (var cat in categories) {
      print('   - ${cat.name} (${cat.category.name.toUpperCase()}) - ${cat.articleCount} articles');
    }
    
    if (categories.isEmpty) {
      print('⚠️ No categories returned from backend!');
      throw Exception('No categories available. Please add categories in the admin panel.');
    }
    
    return categories;
  } catch (e) {
    print('❌ Error loading categories: $e');
    // Don't use fallback - force error so user knows to fix backend
    rethrow;
  }
});

final trendingCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    final repository = ref.read(categoriesRepositoryProvider);
    return await repository.getTrendingCategories();
  } catch (e) {
    print('❌ Error in trending categories provider: $e');
    // Return empty list instead of default categories
    return <CategoryModel>[];
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