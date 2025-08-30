// lib/features/articles/repositories/articles_repository.dart
import '../../../core/network/api_client.dart';
import '../models/article_model.dart';

class ArticlesRepository {
  final ApiClient _apiClient;

  ArticlesRepository(this._apiClient);

  Future<PaginatedResponse<Article>> getArticles({
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy,
    String? order,
    bool? featured,
  }) async {
    try {
      final response = await _apiClient.get(
        '/articles',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          if (sortBy != null) 'sortBy': sortBy,
          if (order != null) 'order': order,
          if (featured != null) 'featured': featured,
        },
      );

      // Handle the API response structure based on your logs
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          // Extract articles array
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();

          // Extract pagination data
          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<Article>(
            data: articles,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? articles.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      // Fallback for unexpected response structure
      return PaginatedResponse<Article>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getArticles: $e');
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Article> getArticleById(String id, {bool trackView = true}) async {
    try {
      final response = await _apiClient.get(
        '/articles/$id',
        queryParameters: {
          if (trackView) 'trackView': 'true',
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return Article.fromJson(data);
        }
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load article: $e');
    }
  }

  Future<PaginatedResponse<Article>> getTrendingArticles({
    int limit = 10,
    String timeframe = '7d',
  }) async {
    try {
      final response = await _apiClient.get(
        '/articles/trending/list',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      // Handle the trending articles response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          // Extract articles array
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();
          
          return PaginatedResponse<Article>(
            data: articles,
            page: 1,
            limit: limit,
            total: articles.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      return PaginatedResponse<Article>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getTrendingArticles: $e');
      throw Exception('Failed to load trending articles: $e');
    }
  }

  Future<PaginatedResponse<Article>> getArticlesByCategory(
    String category, {
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? order,
  }) async {
    try {
      final response = await _apiClient.get(
        '/categories/$category/articles',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (sortBy != null) 'sortBy': sortBy,
          if (order != null) 'order': order,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<Article>(
            data: articles,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? articles.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      return PaginatedResponse<Article>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getArticlesByCategory: $e');
      throw Exception('Failed to load articles by category: $e');
    }
  }

  Future<PaginatedResponse<Article>> searchArticles(
    String query, {
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy,
    String? order,
    String? dateFrom,
    String? dateTo,
    String? author,
  }) async {
    try {
      final response = await _apiClient.get(
        '/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          if (sortBy != null) 'sortBy': sortBy,
          if (order != null) 'order': order,
          if (dateFrom != null) 'dateFrom': dateFrom,
          if (dateTo != null) 'dateTo': dateTo,
          if (author != null) 'author': author,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<Article>(
            data: articles,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? articles.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      return PaginatedResponse<Article>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in searchArticles: $e');
      throw Exception('Failed to search articles: $e');
    }
  }

  Future<List<String>> getSearchSuggestions(String query, {int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/search/suggestions',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is List) {
          return List<String>.from(data);
        }
      }
      
      return [];
    } catch (e) {
      print('Error in getSearchSuggestions: $e');
      return [];
    }
  }

  Future<PaginatedResponse<Article>> getRelatedArticles(
    String articleId, {
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.get(
        '/articles/$articleId/related',
        queryParameters: {
          'limit': limit,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();
          
          return PaginatedResponse<Article>(
            data: articles,
            page: 1,
            limit: limit,
            total: articles.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      return PaginatedResponse<Article>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getRelatedArticles: $e');
      throw Exception('Failed to load related articles: $e');
    }
  }

  Future<PaginatedResponse<Article>> getPopularArticles({
    String timeframe = '7d',
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/articles/popular',
        queryParameters: {
          'timeframe': timeframe,
          'limit': limit,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();
          
          return PaginatedResponse<Article>(
            data: articles,
            page: 1,
            limit: limit,
            total: articles.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      return PaginatedResponse<Article>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getPopularArticles: $e');
      throw Exception('Failed to load popular articles: $e');
    }
  }

  Future<void> shareArticle(String articleId) async {
    try {
      await _apiClient.post('/articles/$articleId/share');
    } catch (e) {
      throw Exception('Failed to share article: $e');
    }
  }

  Future<void> trackArticleView(String articleId) async {
    try {
      await _apiClient.post('/articles/$articleId/view');
    } catch (e) {
      print('Failed to track article view: $e');
      // Don't throw error for view tracking
    }
  }
}