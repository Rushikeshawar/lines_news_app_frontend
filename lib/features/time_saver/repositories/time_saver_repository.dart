// lib/features/time_saver/repositories/time_saver_repository.dart
import '../../../core/network/api_client.dart';
import '../models/time_saver_model.dart';

class TimeSaverRepository {
  final ApiClient _apiClient;

  TimeSaverRepository(this._apiClient);

  Future<PaginatedResponse<TimeSaverContent>> getTimeSaverContent({
    int page = 1,
    int limit = 20,
    String? category,
    String? sortBy = 'publishedAt',
    String? order = 'desc',
  }) async {
    try {
      final response = await _apiClient.get(
        '/time-saver/content',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          'sortBy': sortBy,
          'order': order,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final contentData = data['content'] as List<dynamic>? ?? [];
          final content = contentData.map((contentJson) => 
            TimeSaverContent.fromJson(contentJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<TimeSaverContent>(
            data: content,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? content.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      return PaginatedResponse<TimeSaverContent>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      throw Exception('Failed to load time saver content: $e');
    }
  }

  Future<QuickStats> getQuickStats() async {
    try {
      final response = await _apiClient.get('/time-saver/stats');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return QuickStats.fromJson(data);
        }
      }
      
      // Return default stats if API fails
      return QuickStats(
        storiesCount: 42,
        updatesCount: 28,
        breakingCount: 5,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return QuickStats(
        storiesCount: 42,
        updatesCount: 28,
        breakingCount: 5,
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<PaginatedResponse<QuickUpdateModel>> getTrendingUpdates({
    int limit = 10,
    String timeframe = '24h',
  }) async {
    try {
      final response = await _apiClient.get(
        '/time-saver/trending-updates',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final updatesData = data['updates'] as List<dynamic>? ?? [];
          final updates = updatesData.map((updateJson) => 
            QuickUpdateModel.fromJson(updateJson as Map<String, dynamic>)
          ).toList();
          
          return PaginatedResponse<QuickUpdateModel>(
            data: updates,
            page: 1,
            limit: limit,
            total: updates.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      return PaginatedResponse<QuickUpdateModel>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      throw Exception('Failed to load trending updates: $e');
    }
  }

  Future<PaginatedResponse<BreakingNewsModel>> getBreakingNews({
    int limit = 10,
    String? category,
  }) async {
    try {
      final response = await _apiClient.get(
        '/time-saver/breaking-news',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final newsData = data['news'] as List<dynamic>? ?? [];
          final news = newsData.map((newsJson) => 
            BreakingNewsModel.fromJson(newsJson as Map<String, dynamic>)
          ).toList();
          
          return PaginatedResponse<BreakingNewsModel>(
            data: news,
            page: 1,
            limit: limit,
            total: news.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      return PaginatedResponse<BreakingNewsModel>(
        data: [],
        page: 1,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      throw Exception('Failed to load breaking news: $e');
    }
  }

  Future<Map<String, dynamic>> getTimeSaverAnalytics({
    String timeframe = '7d',
  }) async {
    try {
      final response = await _apiClient.get(
        '/time-saver/analytics',
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
      return {};
    }
  }

  Future<void> trackContentView(String contentId) async {
    try {
      await _apiClient.post('/time-saver/content/$contentId/view');
    } catch (e) {
      print('Failed to track content view: $e');
    }
  }

  Future<void> trackContentInteraction(String contentId, String interactionType) async {
    try {
      await _apiClient.post(
        '/time-saver/content/$contentId/interaction',
        data: {
          'interactionType': interactionType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to track content interaction: $e');
    }
  }

  Future<List<String>> getContentCategories() async {
    try {
      final response = await _apiClient.get('/time-saver/categories');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is List) {
          return List<String>.from(data);
        }
      }
      
      return ['Business', 'Technology', 'Sports', 'Politics', 'Health'];
    } catch (e) {
      return ['Business', 'Technology', 'Sports', 'Politics', 'Health'];
    }
  }

  Future<PaginatedResponse<TimeSaverContent>> searchTimeSaverContent(
    String query, {
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      final response = await _apiClient.get(
        '/time-saver/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final contentData = data['content'] as List<dynamic>? ?? [];
          final content = contentData.map((contentJson) => 
            TimeSaverContent.fromJson(contentJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<TimeSaverContent>(
            data: content,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? content.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      return PaginatedResponse<TimeSaverContent>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      throw Exception('Failed to search time saver content: $e');
    }
  }
}