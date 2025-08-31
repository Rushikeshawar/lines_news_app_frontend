// lib/features/ai_ml/providers/ai_ml_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../articles/models/article_model.dart';
import '../../articles/repositories/articles_repository.dart';
import '../repositories/ai_ml_repository.dart';
import '../../ai_ml/models/ai_news_model.dart';

// Repository provider
final aiMlRepositoryProvider = Provider<AiMlRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AiMlRepository(apiClient);
});

// AI/ML News List class
class AiNewsList {
  final List<AiNewsModel> articles;
  final int page;
  final int totalPages;
  final bool hasNext;
  final bool isLoadingMore;

  AiNewsList({
    required this.articles,
    this.page = 1,
    this.totalPages = 1,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  AiNewsList copyWith({
    List<AiNewsModel>? articles,
    int? page,
    int? totalPages,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return AiNewsList(
      articles: articles ?? this.articles,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// Main AI/ML provider
final aiMlProvider = StateNotifierProvider<AiMlNotifier, AsyncValue<AiNewsList>>((ref) {
  return AiMlNotifier(ref.read(aiMlRepositoryProvider));
});

class AiMlNotifier extends StateNotifier<AsyncValue<AiNewsList>> {
  final AiMlRepository _repository;
  
  AiMlNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAiNews();
  }
  
  Future<void> loadAiNews({
    int page = 1,
    String? category,
    String? sortBy = 'publishedAt',
    String? order = 'desc',
  }) async {
    try {
      print('AiMlNotifier: Loading AI news - page: $page');
      
      if (page == 1) {
        state = const AsyncValue.loading();
      } else {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
        }
      }
      
      final result = await _repository.getAiNews(
        page: page,
        category: category,
        sortBy: sortBy,
        order: order,
      );
      
      print('AiMlNotifier: Got ${result.data.length} articles from repository');
      
      final articles = page == 1 
          ? result.data
          : [...(state.value?.articles ?? <AiNewsModel>[]), ...result.data];
      
      final newsList = AiNewsList(
        articles: articles,
        page: result.page,
        totalPages: result.totalPages,
        hasNext: result.hasNextPage,
        isLoadingMore: false,
      );
      
      print('AiMlNotifier: Setting state with ${newsList.articles.length} total articles');
      state = AsyncValue.data(newsList);
      
    } catch (e, stackTrace) {
      print('AiMlNotifier: Error loading AI news: $e');
      print('Stack trace: $stackTrace');
      
      if (page == 1) {
        state = AsyncValue.error(e, stackTrace);
      } else {
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
        }
      }
    }
  }
  
  Future<void> refresh() async {
    print('AiMlNotifier: Refreshing AI news');
    await loadAiNews(page: 1);
  }
  
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasNext) {
      return;
    }
    
    await loadAiNews(page: currentState.page + 1);
  }
}

// Trending AI provider - Fixed with proper error handling
final trendingAiProvider = FutureProvider<List<AiNewsModel>>((ref) async {
  try {
    print('TrendingAiProvider: Fetching trending AI news');
    final repository = ref.read(aiMlRepositoryProvider);
    final result = await repository.getTrendingAiNews(limit: 6);
    print('TrendingAiProvider: Successfully got ${result.data.length} trending articles');
    return result.data;
  } catch (e, stackTrace) {
    print('TrendingAiProvider: Error fetching trending AI news: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Failed to fetch trending AI news: $e');
  }
});

// AI categories provider
final aiCategoriesProvider = FutureProvider<List<AiCategoryModel>>((ref) async {
  try {
    final repository = ref.read(aiMlRepositoryProvider);
    return await repository.getAiCategories();
  } catch (e) {
    print('Failed to fetch AI categories: $e');
    return AiCategoryHelper.getDefaultCategories();
  }
});

// Popular AI topics provider
final popularAiTopicsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final repository = ref.read(aiMlRepositoryProvider);
    return await repository.getPopularAiTopics();
  } catch (e) {
    return ['ChatGPT', 'Machine Learning', 'Deep Learning', 'Computer Vision', 'NLP'];
  }
});