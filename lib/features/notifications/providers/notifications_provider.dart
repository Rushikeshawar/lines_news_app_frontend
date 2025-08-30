// lib/features/notifications/providers/notifications_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/notifications_repository.dart';
import '../models/notification_model.dart';

// Repository provider
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationsRepository(apiClient);
});

// Notifications list provider
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  try {
    final repository = ref.read(notificationsRepositoryProvider);
    final result = await repository.getNotifications();
    return result.data;
  } catch (e) {
    print('Error fetching notifications: $e');
    throw Exception('Failed to fetch notifications: $e');
  }
});

// Unread count provider
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  try {
    final repository = ref.read(notificationsRepositoryProvider);
    return await repository.getUnreadCount();
  } catch (e) {
    print('Error fetching unread count: $e');
    return 0;
  }
});

// Notifications actions provider
final notificationsActionsProvider = Provider<NotificationsActions>((ref) {
  return NotificationsActions(ref.read(notificationsRepositoryProvider), ref);
});

class NotificationsActions {
  final NotificationsRepository _repository;
  final Ref _ref;
  
  NotificationsActions(this._repository, this._ref);
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      // Refresh the providers
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      // Refresh the providers
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      // Refresh the providers
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  Future<void> clearAllNotifications() async {
    try {
      await _repository.clearAllNotifications();
      // Refresh the providers
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}