// lib/features/ai_ml/repositories/ai_ml_repository.dart
import '../../../core/network/api_client.dart';
import '../../ai_ml/models/ai_news_model.dart';

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

class AiMlRepository {
  final ApiClient _apiClient;

  AiMlRepository(this._apiClient);

  Future<PaginatedResponse<AiNewsModel>> getAiNews({
    int page = 1,
    int limit = 20,
    String? category,
    String? sortBy = 'publishedAt',
    String? order = 'desc',
  }) async {
    try {
      print('Getting AI news - page: $page, limit: $limit, category: $category');
      
      final response = await _apiClient.get(
        '/ai-ml/news',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null && category != 'ALL') 'category': category,
          'sortBy': sortBy,
          'order': order,
        },
      );

      print('AI News API Response: ${response.data}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          print('Processing ${articlesData.length} articles');
          
          final articles = <AiNewsModel>[];
          
          for (final articleJson in articlesData) {
            try {
              final article = AiNewsModel.fromJson(articleJson as Map<String, dynamic>);
              articles.add(article);
              print('Successfully parsed article: ${article.headline}');
            } catch (e, stackTrace) {
              print('Failed to parse article: $e');
              print('Stack trace: $stackTrace');
              print('Article JSON: $articleJson');
            }
          }

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          final result = PaginatedResponse<AiNewsModel>(
            data: articles,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? articles.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
          
          print('Returning ${result.data.length} articles');
          return result;
        }
      }

      return PaginatedResponse<AiNewsModel>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e, stackTrace) {
      print('Error in getAiNews: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load AI/ML news: $e');
    }
  }

  Future<PaginatedResponse<AiNewsModel>> getTrendingAiNews({
    int limit = 10,
    String timeframe = '7d',
  }) async {
    try {
      print('Getting trending AI news - limit: $limit, timeframe: $timeframe');
      
      final response = await _apiClient.get(
        '/ai-ml/trending',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      print('Trending API Response: ${response.data}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articlesData = data['articles'] as List<dynamic>? ?? [];
          print('Processing ${articlesData.length} trending articles');
          
          final articles = <AiNewsModel>[];
          
          for (final articleJson in articlesData) {
            try {
              final article = AiNewsModel.fromJson(articleJson as Map<String, dynamic>);
              articles.add(article);
              print('Successfully parsed trending article: ${article.headline}');
            } catch (e, stackTrace) {
              print('Failed to parse trending article: $e');
              print('Stack trace: $stackTrace');
              print('Article JSON: $articleJson');
            }
          }
          
          final result = PaginatedResponse<AiNewsModel>(
            data: articles,
            page: 1,
            limit: limit,
            total: articles.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
          
          print('Returning ${result.data.length} trending articles');
          return result;
        }
      }

      return PaginatedResponse<AiNewsModel>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e, stackTrace) {
      print('Error in getTrendingAiNews: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load trending AI/ML news: $e');
    }
  }

  Future<AiNewsModel?> getAiArticleById(String articleId) async {
    try {
      print('Getting AI article by ID: $articleId');
      
      // CORRECTED PATH - matches backend route /api/ai-ml/news/:id
      final response = await _apiClient.get('/ai-ml/news/$articleId');
      
      print('Article detail API response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final articleData = data['article'] as Map<String, dynamic>?;
          if (articleData != null) {
            final article = AiNewsModel.fromJson(articleData);
            print('Successfully loaded article: ${article.headline}');
            return article;
          }
        }
      }
      
      print('No article data found in response');
      return null;
    } catch (e, stackTrace) {
      print('Error getting AI article by ID: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // SEARCH FUNCTIONALITY - Backend supported
  Future<PaginatedResponse<AiNewsModel>> searchAiNews(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
    String? sortBy,
    String? order,
  }) async {
    try {
      print('Searching AI news: $query');
      
      final response = await _apiClient.get(
        '/ai-ml/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
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
            AiNewsModel.fromJson(articleJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<AiNewsModel>(
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

      return PaginatedResponse<AiNewsModel>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error searching AI news: $e');
      throw Exception('Failed to search AI/ML news: $e');
    }
  }

  // TRACK VIEW - Backend supported
  Future<void> trackAiArticleView(String articleId) async {
    try {
      print('Tracking view for article: $articleId');
      
      // CORRECTED PATH - matches backend route POST /api/ai-ml/news/:id/view
      await _apiClient.post(
        '/ai-ml/news/$articleId/view',
        data: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('View tracked successfully');
    } catch (e) {
      print('Error tracking article view: $e');
      // Don't throw - tracking errors shouldn't break the app
      // This is optional tracking, so we silently fail
    }
  }

  // TRACK INTERACTION - Backend supported (SHARE, BOOKMARK, LIKE, COMMENT, DOWNLOAD)
  Future<void> trackAiArticleInteraction(
    String articleId, 
    String interactionType,
  ) async {
    try {
      print('Tracking $interactionType for article: $articleId');
      
      // Validate interaction type
      const validTypes = ['SHARE', 'BOOKMARK', 'LIKE', 'COMMENT', 'DOWNLOAD'];
      if (!validTypes.contains(interactionType)) {
        print('Invalid interaction type: $interactionType');
        return;
      }
      
      // CORRECTED PATH - matches backend route POST /api/ai-ml/news/:id/interaction
      await _apiClient.post(
        '/ai-ml/news/$articleId/interaction',
        data: {
          'interactionType': interactionType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('$interactionType interaction tracked successfully');
    } catch (e) {
      print('Error tracking article interaction: $e');
      // Don't throw - tracking errors shouldn't break the app
      // This is optional tracking, so we silently fail
    }
  }

  Future<List<AiCategoryModel>> getAiCategories() async {
    try {
      final response = await _apiClient.get('/ai-ml/categories');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final categoriesData = data['categories'] as List<dynamic>? ?? [];
          return categoriesData.map((categoryJson) => 
            AiCategoryModel.fromJson(categoryJson as Map<String, dynamic>)
          ).toList();
        }
      }
      
      return AiCategoryHelper.getDefaultCategories();
    } catch (e) {
      print('Error getting AI categories: $e');
      return AiCategoryHelper.getDefaultCategories();
    }
  }

  Future<List<String>> getPopularAiTopics({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/ai-ml/topics/popular',
        queryParameters: {
          'limit': limit,
        },
      );
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final topics = data['topics'] as List<dynamic>? ?? [];
          return topics.map((topic) {
            if (topic is Map<String, dynamic>) {
              return topic['topic']?.toString() ?? '';
            }
            return topic.toString();
          }).where((topic) => topic.isNotEmpty).toList();
        }
      }
      
      return ['ChatGPT', 'Machine Learning', 'Deep Learning', 'Computer Vision', 'NLP'];
    } catch (e) {
      print('Error getting popular topics: $e');
      return ['ChatGPT', 'Machine Learning', 'Deep Learning', 'Computer Vision', 'NLP'];
    }
  }

  Future<Map<String, dynamic>> getAiInsights({String timeframe = '30d'}) async {
    try {
      final response = await _apiClient.get(
        '/ai-ml/insights',
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
      print('Error getting AI insights: $e');
      return {};
    }
  }
}