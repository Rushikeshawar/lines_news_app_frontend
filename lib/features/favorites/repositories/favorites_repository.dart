// lib/features/favorites/repositories/favorites_repository.dart - FIXED VERSION
import '../../../core/network/api_client.dart';
import '../models/favorite_model.dart';

class FavoritesRepository {
  final ApiClient _apiClient;

  FavoritesRepository(this._apiClient);

  Future<PaginatedResponse<UserFavorite>> getFavorites({
    int page = 1,
    int limit = 20,
    String? category,
    String? sortBy = 'savedAt',
    String? order = 'desc',
  }) async {
    try {
      final response = await _apiClient.get(
        '/favorites',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          'sortBy': sortBy,
          'order': order,
        },
      );

      // Handle the specific response structure from your API
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data.containsKey('articles')) {
          // Convert articles list to UserFavorite list
          final articles = data['articles'] as List<dynamic>? ?? [];
          final favorites = articles.map((article) => 
            UserFavorite.fromJson(article as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<UserFavorite>(
            data: favorites,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? favorites.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      // Fallback to the original structure
      return PaginatedResponse.fromJson(
        response.data['data'],
        (json) => UserFavorite.fromJson(json),
      );
    } catch (e) {
      print('Error in getFavorites: $e'); // Debug print
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<void> addFavorite(String articleId) async {
    try {
      await _apiClient.post('/favorites/$articleId');
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String articleId) async {
    try {
      await _apiClient.delete('/favorites/$articleId');
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  Future<bool> isFavorite(String articleId) async {
    try {
      final response = await _apiClient.get('/favorites/$articleId/status');
      return response.data['data']['isFavorited'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getFavoritesStats() async {
    try {
      final response = await _apiClient.get('/favorites/stats');
      return response.data['data'] ?? {};
    } catch (e) {
      throw Exception('Failed to load favorites statistics: $e');
    }
  }

  Future<void> bulkFavoritesOperation({
    required List<String> articleIds,
    required String action, // 'add' or 'remove'
  }) async {
    try {
      await _apiClient.post(
        '/favorites/bulk',
        data: {
          'articleIds': articleIds,
          'action': action,
        },
      );
    } catch (e) {
      throw Exception('Failed to perform bulk operation: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _apiClient.delete('/favorites');
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  Future<String> exportFavorites({String format = 'json'}) async {
    try {
      final response = await _apiClient.get(
        '/favorites/export',
        queryParameters: {'format': format},
      );
      return response.data.toString();
    } catch (e) {
      throw Exception('Failed to export favorites: $e');
    }
  }
}