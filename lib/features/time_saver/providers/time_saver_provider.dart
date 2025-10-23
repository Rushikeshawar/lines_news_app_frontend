// lib/features/time_saver/providers/time_saver_provider.dart
// UPDATED TO USE YOUR EXISTING ApiClient

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_saver_model.dart';
import '../../../core/network/api_client.dart';

// Provider for TimeSaver content
final timeSaverProvider = StateNotifierProvider<TimeSaverNotifier, AsyncValue<List<TimeSaverContent>>>((ref) {
  return TimeSaverNotifier(ref);
});

// Provider for Quick Stats
final quickStatsProvider = FutureProvider<QuickStats>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get('/time-saver/stats');
    if (response.data['success'] == true) {
      return QuickStats.fromJson(response.data['data']);
    }
    throw Exception('Failed to load stats');
  } catch (e) {
    throw Exception('Error loading stats: $e');
  }
});

class TimeSaverNotifier extends StateNotifier<AsyncValue<List<TimeSaverContent>>> {
  final Ref ref;
  
  TimeSaverNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadTimeSaverContent();
  }

  // Load TimeSaver content with linked articles
  Future<void> loadTimeSaverContent({
    int page = 1,
    int limit = 50,
    String? category,
    String? contentGroup,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final apiClient = ref.read(apiClientProvider);
      
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'includeLinked': 'true', // IMPORTANT: Include linked article details
      };
      
      if (category != null && category != 'ALL') {
        queryParams['category'] = category;
      }
      
      if (contentGroup != null) {
        queryParams['contentGroup'] = contentGroup;
      }

      final response = await apiClient.get(
        '/time-saver/content',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        // ✅ FIXED: Access 'data' directly, not 'data.content'
        final List<dynamic> dataList = response.data['data'] as List;
        final contentList = dataList
            .map((json) => TimeSaverContent.fromJson(json as Map<String, dynamic>))
            .toList();
        
        state = AsyncValue.data(contentList);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load content');
      }
    } catch (e, stackTrace) {
      print('Error loading TimeSaver content: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Get content by ID with full details
  Future<TimeSaverContent?> getContentById(String contentId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      final response = await apiClient.get('/time-saver/content/$contentId');

      if (response.data['success'] == true) {
        // ✅ FIXED: Access 'data' directly
        return TimeSaverContent.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting content by ID: $e');
      return null;
    }
  }

  // Get content by category
  Future<void> loadByCategory(String category) async {
    await loadTimeSaverContent(category: category);
  }

  // Get content by content group
  Future<void> loadByContentGroup(String contentGroup) async {
    await loadTimeSaverContent(contentGroup: contentGroup);
  }

  // Track view for a TimeSaver content
  Future<void> trackView(String contentId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.post('/time-saver/content/$contentId/view');
      
      // Update the view count locally
      state.whenData((contentList) {
        final updatedList = contentList.map((content) {
          if (content.id == contentId) {
            return content.copyWith(viewCount: content.viewCount + 1);
          }
          return content;
        }).toList();
        
        state = AsyncValue.data(updatedList);
      });
    } catch (e) {
      print('Error tracking view: $e');
      // Don't throw error - tracking should fail silently
    }
  }

  // Track interaction for a TimeSaver content
  Future<void> trackInteraction(String contentId, String interactionType) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      await apiClient.post(
        '/time-saver/content/$contentId/interaction',
        data: {'interactionType': interactionType},
      );
    } catch (e) {
      print('Error tracking interaction: $e');
      // Don't throw error - tracking should fail silently
    }
  }

  // Refresh content
  Future<void> refresh() async {
    await loadTimeSaverContent();
  }
}

// Provider for content by article
final contentByArticleProvider = FutureProvider.family<List<TimeSaverContent>, String>((ref, articleId) async {
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    final response = await apiClient.get('/time-saver/by-article/$articleId');
    
    if (response.data['success'] == true) {
      // ✅ FIXED: Access 'data' directly
      final List<dynamic> dataList = response.data['data'] as List;
      return dataList
          .map((json) => TimeSaverContent.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load content');
  } catch (e) {
    print('Error loading content by article: $e');
    throw Exception('Error: $e');
  }
});