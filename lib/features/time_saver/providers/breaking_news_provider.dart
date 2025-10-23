// lib/features/time_saver/providers/breaking_news_provider.dart
// UPDATED TO USE YOUR EXISTING ApiClient

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breaking_news_model.dart';
import '../../../core/network/api_client.dart';

final breakingNewsProvider = StateNotifierProvider<BreakingNewsNotifier, AsyncValue<List<BreakingNewsModel>>>((ref) {
  return BreakingNewsNotifier(ref);
});

class BreakingNewsNotifier extends StateNotifier<AsyncValue<List<BreakingNewsModel>>> {
  final Ref ref;

  BreakingNewsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadBreakingNews();
  }

  Future<void> loadBreakingNews({
    int page = 1,
    int limit = 20,
    BreakingPriority? priority,
  }) async {
    try {
      state = const AsyncValue.loading();

      final apiClient = ref.read(apiClientProvider);

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'contentType': 'BREAKING',
      };

      if (priority != null) {
        queryParams['priority'] = priority.name.toUpperCase();
      }

      final response = await apiClient.get(
        '/time-saver/content',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final newsList = (response.data['data']['content'] as List)
            .map((json) => BreakingNewsModel.fromJson(json))
            .toList();

        state = AsyncValue.data(newsList);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load breaking news');
      }
    } catch (e, stackTrace) {
      print('Error loading breaking news: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<BreakingNewsModel?> getBreakingNewsById(String newsId) async {
    try {
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.get('/time-saver/content/$newsId');

      if (response.data['success'] == true) {
        return BreakingNewsModel.fromJson(response.data['data']['content']);
      }
      return null;
    } catch (e) {
      print('Error getting breaking news by ID: $e');
      return null;
    }
  }

  Future<void> trackView(String newsId) async {
    try {
      final apiClient = ref.read(apiClientProvider);

      await apiClient.post('/time-saver/content/$newsId/view');

      // Update view count locally
      state.whenData((newsList) {
        final updatedList = newsList.map((news) {
          if (news.id == newsId) {
            return news.copyWith(viewCount: news.viewCount + 1);
          }
          return news;
        }).toList();

        state = AsyncValue.data(updatedList);
      });
    } catch (e) {
      print('Error tracking breaking news view: $e');
    }
  }

  Future<void> refresh() async {
    await loadBreakingNews();
  }
}