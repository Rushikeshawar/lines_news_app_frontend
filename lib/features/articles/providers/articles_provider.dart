// lib/features/articles/providers/articles_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/article_model.dart';
import '../repositories/articles_repository.dart';

// Repository provider
final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ArticlesRepository(apiClient);
});

// Enhanced ArticlesList class
class ArticlesList {
  final List<Article> articles;
  final int page;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final bool isLoadingMore;
  final DateTime lastUpdated;

  ArticlesList({
    required this.articles,
    this.page = 1,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrev = false,
    this.isLoadingMore = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  ArticlesList copyWith({
    List<Article>? articles,
    int? page,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
    bool? isLoadingMore,
    DateTime? lastUpdated,
  }) {
    return ArticlesList(
      articles: articles ?? this.articles,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Main articles provider that fetches latest news
final articlesProvider = StateNotifierProvider<ArticlesNotifier, AsyncValue<ArticlesList>>((ref) {
  return ArticlesNotifier(ref.read(articlesRepositoryProvider));
});

// Latest articles provider - specifically for latest news
final latestArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticles(
      limit: 20,
      sortBy: 'publishedAt', // Sort by published date
      order: 'desc', // Latest first
    );
    
    // Additional client-side sorting to ensure latest first
    final articles = List<Article>.from(result.data);
    articles.sort((a, b) {
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate); // Descending order (latest first)
    });
    
    return articles;
  } catch (e) {
    print('Failed to fetch latest articles: $e');
    throw Exception('Failed to fetch latest articles: $e');
  }
});

// Trending articles provider - fetches from API
final trendingArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getTrendingArticles(limit: 6);
    return result.data;
  } catch (e) {
    print('Failed to fetch trending articles: $e');
    throw Exception('Failed to fetch trending articles: $e');
  }
});

class ArticlesNotifier extends StateNotifier<AsyncValue<ArticlesList>> {
  final ArticlesRepository _repository;
  
  ArticlesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadArticles();
  }
  
  Future<void> loadArticles({
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy = 'publishedAt', // Default to sorting by published date
    String? order = 'desc', // Default to descending (latest first)
  }) async {
    try {
      if (page == 1) {
        state = const AsyncValue.loading();
      } else {
        // Show loading more state
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));
        }
      }
      
      final result = await _repository.getArticles(
        page: page,
        limit: limit,
        category: category,
        sortBy: sortBy,
        order: order,
      );
      
      // Ensure articles are sorted by latest
      final sortedArticles = List<Article>.from(result.data);
      sortedArticles.sort((a, b) {
        final aDate = a.publishedAt ?? a.createdAt;
        final bDate = b.publishedAt ?? b.createdAt;
        return bDate.compareTo(aDate); // Latest first
      });
      
      final List<Article> articles = page == 1 
          ? sortedArticles
          : [...(state.value?.articles ?? <Article>[]), ...sortedArticles];
      
      final articlesList = ArticlesList(
        articles: articles,
        page: result.page,
        totalPages: result.totalPages,
        hasNext: result.hasNextPage,
        hasPrev: result.hasPrevPage,
        isLoadingMore: false,
        lastUpdated: DateTime.now(),
      );
      
      state = AsyncValue.data(articlesList);
      
    } catch (e, stackTrace) {
      print('Error loading articles: $e');
      if (page == 1) {
        state = AsyncValue.error(e, stackTrace);
      } else {
        // For load more errors, just update loading state
        final currentState = state.value;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
        }
      }
    }
  }
  
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasNext) {
      return;
    }
    
    await loadArticles(page: currentState.page + 1);
  }
  
  Future<void> refresh() async {
    await loadArticles(page: 1);
  }
  
  // Load articles by specific criteria
  Future<void> loadLatestArticles() async {
    await loadArticles(
      page: 1,
      sortBy: 'publishedAt',
      order: 'desc',
      limit: 15,
    );
  }
  
  Future<void> loadArticlesByCategory(String category) async {
    await loadArticles(
      page: 1,
      category: category,
      sortBy: 'publishedAt',
      order: 'desc',
    );
  }
}

// Featured articles provider
final featuredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticles(
      limit: 5,
      featured: true,
      sortBy: 'publishedAt',
      order: 'desc',
    );
    return result.data;
  } catch (e) {
    print('Failed to fetch featured articles: $e');
    return <Article>[];
  }
});

// Popular articles provider  
final popularArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getPopularArticles(
      timeframe: '7d', // Last 7 days
      limit: 10,
    );
    return result.data;
  } catch (e) {
    print('Failed to fetch popular articles: $e');
    return <Article>[];
  }
});

// Article by category provider
final articlesByCategoryProvider = FutureProvider.family<List<Article>, String>((ref, categoryName) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticlesByCategory(
      categoryName.toUpperCase(),
      limit: 50,
      sortBy: 'publishedAt',
      order: 'desc',
    );
    
    // Ensure latest first sorting
    final articles = List<Article>.from(result.data);
    articles.sort((a, b) {
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    return articles;
  } catch (e) {
    print('Failed to fetch articles for category $categoryName: $e');
    throw Exception('Failed to fetch articles for category $categoryName: $e');
  }
});

// Single article provider
final articleByIdProvider = FutureProvider.family<Article?, String>((ref, articleId) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final article = await repository.getArticleById(articleId, trackView: true);
    return article;
  } catch (e) {
    print('Error fetching article $articleId: $e');
    return null;
  }
});

// Related articles provider
final relatedArticlesProvider = FutureProvider.family<List<Article>, String>((ref, articleId) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getRelatedArticles(articleId, limit: 5);
    return result.data;
  } catch (e) {
    print('Error fetching related articles for $articleId: $e');
    return <Article>[];
  }
});

// Search functionality
class SearchResults {
  final List<Article> data;
  final int page;
  final int totalPages;
  final int totalCount;
  final String query;
  final DateTime searchTime;
  
  SearchResults({
    required this.data,
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.query,
    DateTime? searchTime,
  }) : searchTime = searchTime ?? DateTime.now();
}

// Search articles provider
final searchArticlesProvider = FutureProvider.family<SearchResults, Map<String, dynamic>>((ref, params) async {
  final query = params['query'] as String? ?? '';
  final page = params['page'] as int? ?? 1;
  final limit = params['limit'] as int? ?? 10;
  final category = params['category'] as String?;
  
  if (query.isEmpty) {
    return SearchResults(
      data: <Article>[], 
      page: page, 
      totalPages: 0, 
      totalCount: 0,
      query: query,
    );
  }
  
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.searchArticles(
      query,
      page: page,
      limit: limit,
      category: category,
      sortBy: 'publishedAt',
      order: 'desc',
    );
    
    // Sort results by latest
    final articles = List<Article>.from(result.data);
    articles.sort((a, b) {
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    return SearchResults(
      data: articles,
      page: result.page,
      totalPages: result.totalPages,
      totalCount: result.total,
      query: query,
    );
  } catch (e) {
    print('Search failed: $e');
    throw Exception('Search failed: $e');
  }
});

// Search suggestions provider
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return <String>[];
  
  try {
    final repository = ref.read(articlesRepositoryProvider);
    return await repository.getSearchSuggestions(query);
  } catch (e) {
    return <String>[];
  }
});

// Article actions provider for tracking views, shares, etc.
final articleActionsProvider = Provider<ArticleActions>((ref) {
  return ArticleActions(ref.read(articlesRepositoryProvider));
});

class ArticleActions {
  final ArticlesRepository _repository;
  
  ArticleActions(this._repository);
  
  Future<void> trackView(String articleId) async {
    try {
      await _repository.trackArticleView(articleId);
    } catch (e) {
      print('Error tracking view: $e');
    }
  }
  
  Future<void> shareArticle(String articleId) async {
    try {
      await _repository.shareArticle(articleId);
    } catch (e) {
      print('Error sharing article: $e');
      throw Exception('Failed to share article');
    }
  }
  
  Future<void> likeArticle(String articleId) async {
    print('Liking article: $articleId');
    // Add API call when like functionality is implemented
  }
}