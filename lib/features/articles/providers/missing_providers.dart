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
    }
  }
  
  Future<void> likeArticle(String articleId) async {
    print('Liking article: $articleId');
    // Add API call when like functionality is implemented
  }
}

// Provider for articles filtered by category - now uses API
final articlesByCategoryProvider = FutureProvider.family<List<Article>, String>((ref, categoryName) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getArticlesByCategory(
      categoryName.toUpperCase(),
      limit: 50, // Get more articles for category pages
    );
    return result.data;
  } catch (e) {
    print('Failed to fetch articles for category $categoryName: $e');
    throw Exception('Failed to fetch articles for category $categoryName: $e');
  }
});

// Article by ID provider - now uses API
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

// Related articles provider - now uses API
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

// Search provider with paginated results
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

// Search articles provider - now uses API
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
    throw Exception('Search failed: $e');
  }
});

// Popular articles provider - uses API
final popularArticlesProvider = FutureProvider<List<Article>>((ref) async {
  try {
    final repository = ref.read(articlesRepositoryProvider);
    final result = await repository.getPopularArticles(limit: 10);
    return result.data;
  } catch (e) {
    print('Failed to fetch popular articles: $e');
    throw Exception('Failed to fetch popular articles: $e');
  }
});

// Search suggestions provider - uses API
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return <String>[];
  
  try {
    final repository = ref.read(articlesRepositoryProvider);
    return await repository.getSearchSuggestions(query);
  } catch (e) {
    return <String>[];
  }
});