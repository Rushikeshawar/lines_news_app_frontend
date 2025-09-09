// lib/features/articles/providers/missing_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article_model.dart';
import '../repositories/articles_repository.dart';
import '../../../core/network/api_client.dart';

// Repository provider
final articlesRepositoryProvider = Provider<ArticlesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ArticlesRepository(apiClient);
});

// Article actions provider with better error handling
final articleActionsProvider = Provider<ArticleActions>((ref) {
  return ArticleActions(ref.read(articlesRepositoryProvider));
});

class ArticleActions {
  final ArticlesRepository _repository;
  
  ArticleActions(this._repository);
  
  // Track view with graceful error handling
  Future<void> trackView(String articleId) async {
    try {
      await _repository.trackArticleView(articleId);
    } catch (e) {
      print('Error tracking view: $e');
      // Don't throw error - view tracking is not critical functionality
    }
  }
  
  Future<void> shareArticle(String articleId) async {
    try {
      await _repository.shareArticle(articleId);
    } catch (e) {
      print('Error sharing article: $e');
      // Don't throw for share tracking either
    }
  }
  
  Future<void> likeArticle(String articleId) async {
    print('Liking article: $articleId');
    // Add API call when like functionality is implemented
  }
}

// Articles by category provider with better error handling
final articlesByCategoryProvider = FutureProvider.family<List<Article>, String>((ref, categoryName) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticlesByCategory(
      categoryName.toUpperCase(),
      limit: 50,
    );
    return result.data;
  } catch (e) {
    print('Failed to fetch articles for category $categoryName: $e');
    // Return empty list instead of throwing to prevent UI crashes
    return <Article>[];
  }
});

// FIXED: Article by ID provider with enhanced debugging and error handling
final articleByIdProvider = FutureProvider.family<Article?, String>((ref, articleId) async {
  try {
    print('🔍 Provider: Fetching article with ID: $articleId');
    
    final repository = ref.read(articlesRepositoryProvider);
    final article = await repository.getArticleById(articleId, trackView: true);
    
    if (article != null) {
      print('🔍 Provider: Article fetched successfully');
      print('🔍 Provider: Headline: ${article.headline}');
      print('🔍 Provider: Brief content length: ${article.briefContent?.length ?? 0}');
      print('🔍 Provider: Full content length: ${article.fullContent?.length ?? 0}');
      
      if (article.fullContent != null && article.fullContent!.isNotEmpty) {
        print('🔍 Provider: Full content preview: ${article.fullContent!.substring(0, article.fullContent!.length.clamp(0, 100))}...');
      } else {
        print('⚠️ Provider: Full content is null or empty!');
      }
    } else {
      print('⚠️ Provider: Article is null!');
    }
    
    return article;
  } catch (e) {
    print('❌ Provider: Error fetching article $articleId: $e');
    return null;
  }
});

// Related articles provider with graceful fallback
final relatedArticlesProvider = FutureProvider.family<List<Article>, String>((ref, articleId) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getRelatedArticles(articleId, limit: 5);
    return result.data;
  } catch (e) {
    print('Error fetching related articles for $articleId: $e');
    // Return empty list instead of throwing
    return <Article>[];
  }
});

// Search provider with better error handling
class SearchResults {
  final List<Article> data;
  final int page;
  final int totalPages;
  final int totalCount;
  
  SearchResults({
    required this.data,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });
}

final searchArticlesProvider = FutureProvider.family<SearchResults, Map<String, dynamic>>((ref, params) async {
  final query = params['query'] as String? ?? '';
  final page = params['page'] as int? ?? 1;
  final limit = params['limit'] as int? ?? 10;
  final category = params['category'] as String?;
  
  if (query.isEmpty) {
    return SearchResults(data: <Article>[], page: page, totalPages: 0, totalCount: 0);
  }
  
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.searchArticles(
      query,
      page: page,
      limit: limit,
      category: category,
    );
    
    return SearchResults(
      data: result.data,
      page: result.page,
      totalPages: result.totalPages,
      totalCount: result.total,
    );
  } catch (e) {
    print('Search failed: $e');
    // Return empty results instead of throwing
    return SearchResults(data: <Article>[], page: page, totalPages: 0, totalCount: 0);
  }
});

// Popular articles provider with fallback
final popularArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getPopularArticles(limit: 10);
    return result.data;
  } catch (e) {
    print('Failed to fetch popular articles: $e');
    // Return empty list instead of throwing
    return <Article>[];
  }
});

// Search suggestions provider with error handling
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return <String>[];
  
  try {
    final repository = ref.read(articlesRepositoryProvider);
    return await repository.getSearchSuggestions(query);
  } catch (e) {
    print('Failed to get search suggestions: $e');
    return <String>[];
  }
});

// Provider for trending articles with fallback
final trendingArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getTrendingArticles(limit: 6);
    return result.data;
  } catch (e) {
    print('Failed to fetch trending articles: $e');
    // Return empty list instead of throwing
    return <Article>[];
  }
});

// Latest articles provider for home page
final latestArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticles(
      limit: 20,
      sortBy: 'publishedAt',
      order: 'desc',
    );
    
    // Sort by latest to ensure proper ordering
    final articles = List<Article>.from(result.data);
    articles.sort((a, b) {
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    return articles;
  } catch (e) {
    print('Failed to fetch latest articles: $e');
    return <Article>[];
  }
});

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

// Helper extension for safe operations
extension ArticleProviderHelpers on WidgetRef {
  Future<void> safeTrackView(String articleId) async {
    try {
      await read(articleActionsProvider).trackView(articleId);
    } catch (e) {
      print('View tracking failed: $e');
    }
  }
  
  Future<void> safeShareArticle(String articleId) async {
    try {
      await read(articleActionsProvider).shareArticle(articleId);
    } catch (e) {
      print('Share tracking failed: $e');
    }
  }
}

// Debug provider to help troubleshoot data loading issues
final debugArticleProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, articleId) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    
    print('🔍 DEBUG: Starting to fetch article: $articleId');
    
    // Make the raw API call to see what we get
    final article = await repository.getArticleById(articleId, trackView: false);
    
    final debugInfo = {
      'articleId': articleId,
      'articleFound': article != null,
      'headline': article?.headline ?? 'N/A',
      'briefContentLength': article?.briefContent?.length ?? 0,
      'fullContentLength': article?.fullContent?.length ?? 0,
      'fullContentPreview': article?.fullContent?.substring(0, (article?.fullContent?.length ?? 0).clamp(0, 200)) ?? 'N/A',
      'category': article?.category.name ?? 'N/A',
      'publishedAt': article?.publishedAt?.toIso8601String() ?? 'N/A',
      'featuredImage': article?.featuredImage ?? 'N/A',
    };
    
    print('🔍 DEBUG: Article debug info: $debugInfo');
    
    return debugInfo;
  } catch (e) {
    print('🔍 DEBUG: Error in debug provider: $e');
    return {
      'error': e.toString(),
      'articleId': articleId,
    };
  }
});