// lib/features/articles/repositories/articles_repository.dart
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
      print('🔍 Fetching article with ID: $id');
      
      final response = await _apiClient.get(
        '/articles/$id',
        queryParameters: {
          if (trackView) 'trackView': 'true',
        },
      );

      final responseData = response.data;
      print('🔍 Raw response data: $responseData');
      
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        print('🔍 Article data section: $data');
        
        if (data is Map<String, dynamic>) {
          final articleData = data['article'] ?? data;
          print('🔍 Final article data: $articleData');
          
          if (articleData is Map<String, dynamic>) {
            final article = Article.fromJson(articleData);
            print('🔍 Parsed article: ${article.headline}');
            print('🔍 Category: ${article.category} (${article.categoryDisplayName})');
            print('🔍 Full content length: ${article.fullContent?.length ?? 0}');
            return article;
          }
        }
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      print('❌ Error fetching article: $e');
      throw Exception('Failed to load article: $e');
    }
  }

  Future<PaginatedResponse<Article>> getTrendingArticles({
    int limit = 10,
    String timeframe = '7d',
  }) async {
    try {
      print('📈 Fetching trending articles with limit: $limit');
      
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

  Future<PaginatedResponse<Article>> getRelatedArticles(
    String articleId, {
    int limit = 5,
  }) async {
    try {
      print('🔗 Fetching related articles for: $articleId');
      
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
        
        try {
          final article = await getArticleById(articleId, trackView: false);
          
          // FIXED: Use article.category (String) instead of article.category.name
          final categoryArticles = await getArticlesByCategory(
            article.category, // This is already a String like "RUSHI" or "TECHNOLOGY"
            limit: limit + 1,
          );
          
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
      print('✅ Article shared successfully');
    } catch (e) {
      print('❌ Error sharing article: $e');
    }
  }

  Future<void> trackArticleView(String articleId) async {
    try {
      print('👁️ Attempting to track view for article: $articleId');
      
      await _apiClient.post('/articles/$articleId/view');
      print('✅ Successfully tracked article view');
      
    } catch (e) {
      print('❌ Failed to track article view: $e');
      
      if (e.toString().contains('404') || e.toString().contains('Route not found')) {
        print('⚠️ View tracking endpoint not available - this is not critical, continuing...');
        return;
      }
      
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