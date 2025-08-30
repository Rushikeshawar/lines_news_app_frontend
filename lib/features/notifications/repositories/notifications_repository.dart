// lib/features/notifications/repositories/notifications_repository.dart
import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../../articles/models/article_model.dart' show PaginatedResponse;
// At the top of notifications_repository.dart, add:
import 'package:dio/dio.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<PaginatedResponse<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    String? type,
  }) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
          'unreadOnly': unreadOnly,
          if (type != null) 'type': type,
        },
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          final notificationsData = data['notifications'] as List<dynamic>? ?? [];
          final notifications = notificationsData.map((notificationJson) => 
            AppNotification.fromJson(notificationJson as Map<String, dynamic>)
          ).toList();

          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          
          return PaginatedResponse<AppNotification>(
            data: notifications,
            page: pagination['page'] ?? page,
            limit: pagination['limit'] ?? limit,
            total: pagination['totalCount'] ?? notifications.length,
            totalPages: pagination['totalPages'] ?? 1,
            hasNextPage: pagination['hasNext'] ?? false,
            hasPrevPage: pagination['hasPrev'] ?? false,
          );
        }
      }

      return PaginatedResponse<AppNotification>(
        data: [],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    } catch (e) {
      print('Error in getNotifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.put('/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put('/notifications/read-all');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('/notifications/$notificationId');
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _apiClient.delete('/notifications', 
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      // Send the confirmation data as request body if needed
      await _apiClient.post('/notifications/clear', 
        data: {
          'confirm': true,
          'olderThan': 30,
        },
      );
    } catch (e) {
      throw Exception('Failed to clear all notifications: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return data['count'] ?? 0;
        }
      }
      
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}