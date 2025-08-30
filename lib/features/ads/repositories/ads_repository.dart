// lib/features/ads/repositories/ads_repository.dart
import '../../../core/network/api_client.dart';
import '../../articles/models/article_model.dart';

class AdsRepository {
  final ApiClient _apiClient;

  AdsRepository(this._apiClient);

  Future<PaginatedResponse<Advertisement>> getActiveAds({
    AdPosition? position,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/advertisements/active',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (position != null) 'position': position.name.toUpperCase(),
        },
      );

      // Handle the API response structure based on your logs
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          // Extract advertisements array
          final adsData = data['advertisements'] as List<dynamic>? ?? [];
          final advertisements = adsData.map((adJson) => 
            Advertisement.fromJson(adJson as Map<String, dynamic>)
          ).toList();

          return PaginatedResponse<Advertisement>(
            data: advertisements,
            page: page,
            limit: limit,
            total: advertisements.length,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
          );
        }
      }

      // Fallback
      return PaginatedResponse<Advertisement>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getActiveAds: $e');
      throw Exception('Failed to fetch ads: $e');
    }
  }

  Future<Advertisement> getAdById(String id) async {
    try {
      final response = await _apiClient.get('/advertisements/$id');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return Advertisement.fromJson(data);
        }
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch ad: $e');
    }
  }

  Future<void> trackAdClick(String adId) async {
    try {
      await _apiClient.post('/advertisements/$adId/click');
    } catch (e) {
      print('Failed to track ad click: $e');
      // Don't throw error for tracking
    }
  }

  Future<void> trackAdImpression(String adId) async {
    try {
      await _apiClient.post('/advertisements/$adId/impression');
    } catch (e) {
      print('Failed to track ad impression: $e');
      // Don't throw error for tracking
    }
  }
}