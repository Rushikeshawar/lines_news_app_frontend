// lib/features/ads/providers/ads_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../articles/models/article_model.dart';
import '../repositories/ads_repository.dart';

// Repository provider
final adsRepositoryProvider = Provider<AdsRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AdsRepository(apiClient);
});

// Provider for banner ads - now uses API
final bannerAdsProvider = FutureProvider<List<Advertisement>>((ref) async {
  try {
    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.getActiveAds(
      position: AdPosition.banner,
      limit: 10,
    );
    return result.data;
  } catch (e) {
    print('Error fetching banner ads: $e');
    return [];
  }
});

// Provider for all active ads - now uses API
final activeAdsProvider = FutureProvider<List<Advertisement>>((ref) async {
  try {
    final repository = ref.read(adsRepositoryProvider);
    final result = await repository.getActiveAds(limit: 20);
    return result.data;
  } catch (e) {
    print('Error fetching active ads: $e');
    return [];
  }
});

// Ads service provider for tracking clicks and impressions
final adsProvider = Provider<AdsService>((ref) {
  return AdsService(ref.read(adsRepositoryProvider));
});

class AdsService {
  final AdsRepository _repository;
  
  AdsService(this._repository);
  
  Future<void> trackAdClick(String adId) async {
    try {
      await _repository.trackAdClick(adId);
    } catch (e) {
      print('Error tracking ad click: $e');
    }
  }
  
  Future<void> trackAdImpression(String adId) async {
    try {
      await _repository.trackAdImpression(adId);
    } catch (e) {
      print('Error tracking ad impression: $e');
    }
  }
  
  Future<List<Advertisement>> getAdsByPosition(AdPosition position) async {
    try {
      final result = await _repository.getActiveAds(
        position: position,
        limit: 10,
      );
      return result.data;
    } catch (e) {
      print('Error fetching ads by position: $e');
      return [];
    }
  }
}

// Provider for specific ad position - now uses API
final adsByPositionProvider = FutureProvider.family<List<Advertisement>, AdPosition>((ref, position) async {
  final adsService = ref.read(adsProvider);
  return await adsService.getAdsByPosition(position);
});