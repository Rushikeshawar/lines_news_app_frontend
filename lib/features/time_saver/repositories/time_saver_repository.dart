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
      print('Making API call to /time-saver/content');
      
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

      print('Repository raw response: ${response.data}');
      print('Response type: ${response.runtimeType}');
      print('Response status: ${response.statusCode}');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] ?? false;
        print('API Success: $success');
        
        if (success) {
          final data = responseData['data'] as Map<String, dynamic>;
          print('Data keys: ${data.keys}');
          
          final contentData = data['content'] as List<dynamic>? ?? [];
          print('Content count from API: ${contentData.length}');
          
          final content = contentData.map((contentJson) {
            print('Parsing content item: ${contentJson['id']} - ${contentJson['title']}');
            return TimeSaverContent.fromJson(contentJson as Map<String, dynamic>);
          }).toList();

          print('Successfully parsed ${content.length} content items');

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

      print('Returning empty response - API call failed or no success flag');
      return PaginatedResponse<TimeSaverContent>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e, stackTrace) {
      print('Repository error in getTimeSaverContent: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load time saver content: $e');
    }
  }

  Future<QuickStats> getQuickStats() async {
    try {
      print('Making API call to /time-saver/stats');
      
      final response = await _apiClient.get('/time-saver/stats');
      
      print('Stats response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] ?? false;
        if (success) {
          final data = responseData['data'] as Map<String, dynamic>;
          final stats = data['stats'] as Map<String, dynamic>;
          print('Parsed stats: $stats');
          return QuickStats.fromJson(stats);
        }
      }
      
      print('Using fallback stats');
      return QuickStats(
        storiesCount: 0,
        updatesCount: 0,
        breakingCount: 0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Stats error: $e');
      return QuickStats(
        storiesCount: 0,
        updatesCount: 0,
        breakingCount: 0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<PaginatedResponse<QuickUpdateModel>> getTrendingUpdates({
    int limit = 10,
    String timeframe = '24h',
  }) async {
    try {
      print('Making API call to /time-saver/trending-updates');
      
      final response = await _apiClient.get(
        '/time-saver/trending-updates',
        queryParameters: {
          'limit': limit,
          'timeframe': timeframe,
        },
      );

      print('Trending response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] ?? false;
        if (success) {
          final data = responseData['data'] as Map<String, dynamic>;
          final updatesData = data['updates'] as List<dynamic>? ?? [];
          final updates = updatesData.map((updateJson) => 
            QuickUpdateModel.fromJson(updateJson as Map<String, dynamic>)
          ).toList();
          
          print('Parsed ${updates.length} trending updates');
          
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
      print('Trending error: $e');
      throw Exception('Failed to load trending updates: $e');
    }
  }

  Future<PaginatedResponse<BreakingNewsModel>> getBreakingNews({
    int limit = 10,
    String? category,
  }) async {
    try {
      print('Making API call to /time-saver/breaking-news');
      
      final response = await _apiClient.get(
        '/time-saver/breaking-news',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
        },
      );

      print('Breaking news response: ${response.data}');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] ?? false;
        if (success) {
          final data = responseData['data'] as Map<String, dynamic>;
          // IMPORTANT: Your API returns 'breakingNews' field, not 'news'
          final newsData = data['breakingNews'] as List<dynamic>? ?? [];
          final news = newsData.map((newsJson) => 
            BreakingNewsModel.fromJson(newsJson as Map<String, dynamic>)
          ).toList();
          
          print('Parsed ${news.length} breaking news items');
          
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
      print('Breaking news error: $e');
      throw Exception('Failed to load breaking news: $e');
    }
  }
}