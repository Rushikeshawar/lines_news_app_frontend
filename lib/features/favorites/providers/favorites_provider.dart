// lib/features/favorites/providers/favorites_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/favorites_repository.dart';
import '../models/favorite_model.dart';
import '../../../core/network/api_client.dart';

// Repository provider
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return FavoritesRepository(apiClient);
});

// Favorites provider that manages Set<String> of article IDs
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return FavoritesNotifier(repository);
});

// Provider for the actual favorite articles with full data
final favoriteArticlesProvider = StateNotifierProvider<FavoriteArticlesNotifier, AsyncValue<List<UserFavorite>>>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return FavoriteArticlesNotifier(repository);
});

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final FavoritesRepository _repository;
  static const String _favoritesKey = 'user_favorites';

  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      state = const AsyncValue.loading();
      
      // Load from local storage first for immediate UI update
      final localFavorites = await _loadLocalFavorites();
      if (localFavorites.isNotEmpty) {
        state = AsyncValue.data(localFavorites);
      }
      
      // Then fetch from server to sync
      final serverFavorites = await _fetchServerFavorites();
      state = AsyncValue.data(serverFavorites);
      
      // Save to local storage
      await _saveLocalFavorites(serverFavorites);
    } catch (error, stackTrace) {
      debugPrint('Error loading favorites: $error');
      // Fallback to local favorites if server fails
      final localFavorites = await _loadLocalFavorites();
      if (localFavorites.isNotEmpty) {
        state = AsyncValue.data(localFavorites);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<Set<String>> _fetchServerFavorites() async {
    try {
      final response = await _repository.getFavorites();
      debugPrint('Fetched ${response.data.length} favorites from server');
      
      final favoriteIds = response.data
          .map<String>((favorite) => favorite.id)
          .where((id) => id.isNotEmpty)
          .toSet();
      
      debugPrint('Extracted favorite IDs: $favoriteIds');
      return favoriteIds;
    } catch (e) {
      debugPrint('Error fetching server favorites: $e');
      rethrow;
    }
  }

  Future<Set<String>> _loadLocalFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      return favorites.toSet();
    } catch (e) {
      debugPrint('Error loading local favorites: $e');
      return <String>{};
    }
  }

  Future<void> _saveLocalFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites.toList());
    } catch (e) {
      debugPrint('Error saving local favorites: $e');
    }
  }

  Future<void> addFavorite(String articleId) async {
    final currentState = state.asData?.value ?? <String>{};
    final newState = {...currentState, articleId};
    
    // Optimistic update
    state = AsyncValue.data(newState);
    await _saveLocalFavorites(newState);
    
    try {
      await _repository.addFavorite(articleId);
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      // Revert on error
      state = AsyncValue.data(currentState);
      await _saveLocalFavorites(currentState);
      rethrow;
    }
  }

  Future<void> removeFavorite(String articleId) async {
    final currentState = state.asData?.value ?? <String>{};
    final newState = currentState.where((id) => id != articleId).toSet();
    
    // Optimistic update
    state = AsyncValue.data(newState);
    await _saveLocalFavorites(newState);
    
    try {
      await _repository.removeFavorite(articleId);
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      // Revert on error
      state = AsyncValue.data(currentState);
      await _saveLocalFavorites(currentState);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    final currentState = state.asData?.value ?? <String>{};
    
    // Optimistic update
    state = const AsyncValue.data(<String>{});
    await _saveLocalFavorites(<String>{});
    
    try {
      await _repository.clearAllFavorites();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      // Revert on error
      state = AsyncValue.data(currentState);
      await _saveLocalFavorites(currentState);
      rethrow;
    }
  }

  bool isFavorite(String articleId) {
    return state.asData?.value.contains(articleId) ?? false;
  }

  void refresh() {
    _loadFavorites();
  }
}

class FavoriteArticlesNotifier extends StateNotifier<AsyncValue<List<UserFavorite>>> {
  final FavoritesRepository _repository;

  FavoriteArticlesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadFavoriteArticles();
  }

  Future<void> _loadFavoriteArticles() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getFavorites();
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      debugPrint('Error loading favorite articles: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadFavoriteArticles();
  }
}

// Helper provider for checking individual articles
final isArticleFavoritedProvider = Provider.family<bool, String>((ref, articleId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.asData?.value.contains(articleId) ?? false;
});
