// lib/features/time_saver/providers/time_saver_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/time_saver_repository.dart';
import '../models/time_saver_model.dart';

// Repository provider
final timeSaverRepositoryProvider = Provider<TimeSaverRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TimeSaverRepository(apiClient);
});

// Main Time Saver provider
final timeSaverProvider = StateNotifierProvider<TimeSaverNotifier, AsyncValue<List<TimeSaverContent>>>((ref) {
  return TimeSaverNotifier(ref.read(timeSaverRepositoryProvider));
});

class TimeSaverNotifier extends StateNotifier<AsyncValue<List<TimeSaverContent>>> {
  final TimeSaverRepository _repository;
  
  TimeSaverNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTimeSaverContent();
  }
  
  Future<void> loadTimeSaverContent() async {
    try {
      print('TimeSaverNotifier: Starting to load content');
      state = const AsyncValue.loading();
      
      final response = await _repository.getTimeSaverContent();
      print('TimeSaverNotifier: Received ${response.data.length} content items');
      
      // Log the first few items for debugging
      if (response.data.isNotEmpty) {
        for (int i = 0; i < response.data.length && i < 3; i++) {
          final item = response.data[i];
          print('  [$i] ${item.id} - ${item.title}');
        }
      }
      
      state = AsyncValue.data(response.data);
      print('TimeSaverNotifier: Successfully updated state with ${response.data.length} items');
    } catch (e, stackTrace) {
      print('TimeSaverNotifier: Error loading content: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> refresh() async {
    await loadTimeSaverContent();
  }
}

// Quick stats provider
final quickStatsProvider = FutureProvider<QuickStats>((ref) async {
  try {
    print('QuickStatsProvider: Loading stats');
    final repository = ref.read(timeSaverRepositoryProvider);
    final stats = await repository.getQuickStats();
    print('QuickStatsProvider: Loaded stats - stories: ${stats.storiesCount}, updates: ${stats.updatesCount}, breaking: ${stats.breakingCount}');
    return stats;
  } catch (e) {
    print('QuickStatsProvider: Error loading stats: $e');
    return QuickStats(
      storiesCount: 0,
      updatesCount: 0,
      breakingCount: 0,
      lastUpdated: DateTime.now(),
    );
  }
});

// Trending updates provider
final trendingUpdatesProvider = FutureProvider<List<QuickUpdateModel>>((ref) async {
  try {
    print('TrendingUpdatesProvider: Loading trending updates');
    final repository = ref.read(timeSaverRepositoryProvider);
    final result = await repository.getTrendingUpdates(limit: 8);
    print('TrendingUpdatesProvider: Loaded ${result.data.length} trending updates');
    return result.data;
  } catch (e) {
    print('TrendingUpdatesProvider: Error loading trending updates: $e');
    return <QuickUpdateModel>[];
  }
});

// Breaking news provider
final breakingNewsProvider = FutureProvider<List<BreakingNewsModel>>((ref) async {
  try {
    print('BreakingNewsProvider: Loading breaking news');
    final repository = ref.read(timeSaverRepositoryProvider);
    final result = await repository.getBreakingNews(limit: 5);
    print('BreakingNewsProvider: Loaded ${result.data.length} breaking news items');
    return result.data;
  } catch (e) {
    print('BreakingNewsProvider: Error loading breaking news: $e');
    return <BreakingNewsModel>[];
  }
});