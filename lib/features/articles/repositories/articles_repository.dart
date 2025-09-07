// lib/features/articles/repositories/articles_repository.dart - FIXED VERSION
import '../../../core/network/api_client.dart';
import '../models/article_model.dart';

class ArticlesRepository {
  final ApiClient _apiClient;

  ArticlesRepository(this._apiClient);

  Future<PaginatedResponse<Article>> getArticles({
    int page = 1,
    int limit = 100,
    String? category,
    String? sortBy,
    String? order,
    bool? featured,
  }) async {
    try {
      print('📡 Making API request with limit: $limit, page: $page');
      
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

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          print('📰 Found ${articlesData.length} articles in response');
          
          final articles = articlesData.map((articleJson) => 
            Article.fromJson(articleJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          final result = PaginatedResponse<Article>(
            data: articles,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? articles.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
          
          print('✅ Returning ${result.data.length} articles, hasNext: ${result.hasNextPage}');
          return result;
        }
      }

      print('⚠️ Unexpected response structure, returning empty result');
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
      print('❌ Error in getArticles: $e');
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
      print('📈 Fetching trending articles with limit: $limit');
      
      // Try the trending endpoint first
      try {
        final response = await _apiClient.get(
          '/articles/trending/list',
          queryParameters: {
            'limit': limit,
            'timeframe': timeframe,
          },
        );

        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            final articlesData = data['articles'] as List<dynamic>? ?? [];
            print('📈 Found ${articlesData.length} trending articles');
            
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
      } catch (e) {
        print('⚠️ Trending endpoint not available, falling back to regular articles');
        // If trending endpoint doesn't exist, fall back to regular articles sorted by views
        return getArticles(
          limit: limit,
          sortBy: 'viewCount',
          order: 'desc',
        );
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
      print('❌ Error in getTrendingArticles: $e');
      throw Exception('Failed to load trending articles: $e');
    }
  }

  Future<PaginatedResponse<Article>> getArticlesByCategory(
    String category, {
    int page = 1,
    int limit = 100,
    String? sortBy,
    String? order,
  }) async {
    try {
      print('📂 Fetching articles for category: $category, limit: $limit');
      
      // Try category-specific endpoint first
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
            print('📂 Found ${articlesData.length} articles in category $category');
            
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
      } catch (e) {
        print('⚠️ Category endpoint not available, using general articles endpoint with filter');
        // Fall back to general articles endpoint with category filter
        return getArticles(
          page: page,
          limit: limit,
          category: category,
          sortBy: sortBy,
          order: order,
        );
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
      print('❌ Error in getArticlesByCategory: $e');
      throw Exception('Failed to load articles by category: $e');
    }
  }

  Future<PaginatedResponse<Article>> searchArticles(
    String query, {
    int page = 1,
    int limit = 50,
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
      print('❌ Error in searchArticles: $e');
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
      print('❌ Error in getSearchSuggestions: $e');
      return [];
    }
  }

  // FIXED: Handle missing related articles endpoint
  Future<PaginatedResponse<Article>> getRelatedArticles(
    String articleId, {
    int limit = 5,
  }) async {
    try {
      print('🔗 Fetching related articles for: $articleId');
      
      // Try the related articles endpoint first
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
            
            print('✅ Found ${articles.length} related articles');
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
      } catch (e) {
        print('⚠️ Related articles endpoint not available (${e.toString()}), using fallback');
        
        // FALLBACK: Get articles from same category as related articles
        try {
          // First get the article to find its category
          final article = await getArticleById(articleId, trackView: false);
          
          // Then get other articles from the same category
          final categoryArticles = await getArticlesByCategory(
            article.category.name,
            limit: limit + 1, // Get one extra to exclude the current article
          );
          
          // Filter out the current article and limit results
          final relatedArticles = categoryArticles.data
              .where((a) => a.id != articleId)
              .take(limit)
              .toList();
          
          print('✅ Found ${relatedArticles.length} related articles via category fallback');
          return PaginatedResponse<Article>(
            data: relatedArticles,
            page: 1,
            limit: limit,
            total: relatedArticles.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        } catch (fallbackError) {
          print('⚠️ Category fallback also failed: $fallbackError');
          
          // ULTIMATE FALLBACK: Get latest articles
          final latestArticles = await getArticles(
            limit: limit + 1,
            sortBy: 'publishedAt',
            order: 'desc',
          );
          
          final relatedArticles = latestArticles.data
              .where((a) => a.id != articleId)
              .take(limit)
              .toList();
              
          print('✅ Using ${relatedArticles.length} latest articles as related content');
          return PaginatedResponse<Article>(
            data: relatedArticles,
            page: 1,
            limit: limit,
            total: relatedArticles.length,
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
      print('❌ Error in getRelatedArticles: $e');
      // Return empty list instead of throwing to prevent UI crashes
      return PaginatedResponse<Article>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    }
  }

  Future<PaginatedResponse<Article>> getPopularArticles({
    String timeframe = '7d',
    int limit = 20,
  }) async {
    try {
      // Try popular articles endpoint first
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
      } catch (e) {
        print('⚠️ Popular articles endpoint not available, using view count sorting');
        // Fall back to articles sorted by view count
        return getArticles(
          limit: limit,
          sortBy: 'viewCount',
          order: 'desc',
        );
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
      print('❌ Error in getPopularArticles: $e');
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

  // FIXED: Handle missing view tracking endpoint gracefully
  Future<void> trackArticleView(String articleId) async {
    try {
      print('👁️ Attempting to track view for article: $articleId');
      
      // Try the view tracking endpoint
      await _apiClient.post('/articles/$articleId/view');
      print('✅ Successfully tracked article view');
      
    } catch (e) {
      print('❌ Failed to track article view: $e');
      
      // Check if it's a 404 (endpoint doesn't exist)
      if (e.toString().contains('404') || e.toString().contains('Route not found')) {
        print('⚠️ View tracking endpoint not available - this is not critical, continuing...');
        // Don't throw error for missing view tracking - it's not critical functionality
        return;
      }
      
      // For other errors, also don't throw to prevent app crashes
      print('⚠️ View tracking failed with error: $e - continuing without tracking');
    }
  }
}

// Helper class for paginated responses
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}