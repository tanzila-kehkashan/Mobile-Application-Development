import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// User Notifications Stream Providere
final userNotificationsProvider = StreamProvider.family<List<NotificationModel>, String>(
  (ref, userId) {
    final service = ref.watch(notificationServiceProvider);
    return service.getUserNotifications(userId);
  },
);

// Unread Notifications Count Provider
final unreadNotificationsCountProvider = Provider.family<int, String>(
  (ref, userId) {
    final notificationsAsync = ref.watch(userNotificationsProvider(userId));
    return notificationsAsync.when(
      data: (notifications) {
        return notifications.where((n) => !n.isRead).length;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);
