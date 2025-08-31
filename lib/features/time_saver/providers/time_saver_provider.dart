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
      state = const AsyncValue.loading();
      final content = await _repository.getTimeSaverContent();
      state = AsyncValue.data(content.data);
    } catch (e, stackTrace) {
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
    final repository = ref.read(timeSaverRepositoryProvider);
    return await repository.getQuickStats();
  } catch (e) {
    // Fallback stats
    return QuickStats(
      storiesCount: 42,
      updatesCount: 28,
      breakingCount: 5,
      lastUpdated: DateTime.now(),
    );
  }
});

// Trending updates provider
final trendingUpdatesProvider = FutureProvider<List<QuickUpdateModel>>((ref) async {
  try {
    final repository = ref.read(timeSaverRepositoryProvider);
    final result = await repository.getTrendingUpdates(limit: 8);
    return result.data;
  } catch (e) {
    return <QuickUpdateModel>[];
  }
});

// Breaking news provider
final breakingNewsProvider = FutureProvider<List<BreakingNewsModel>>((ref) async {
  try {
    final repository = ref.read(timeSaverRepositoryProvider);
    final result = await repository.getBreakingNews(limit: 5);
    return result.data;
  } catch (e) {
    return <BreakingNewsModel>[];
  }
});
