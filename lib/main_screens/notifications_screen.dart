import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/auth_provider.dart';
import '../services/enhanced_notification_service.dart';
import '../models/app_notification.dart';

/// Provider for enhanced notification service
final enhancedNotificationServiceProvider = Provider<EnhancedNotificationService>((ref) {
  return EnhancedNotificationService();
});

/// Provider for user's notifications stream
final enhancedUserNotificationsProvider = StreamProvider.family<List<AppNotification>, String>(
  (ref, userId) {
    final service = ref.watch(enhancedNotificationServiceProvider);
    return service.getUserNotifications(userId);
  },
);

/// Provider for unread notification count
final enhancedUnreadCountProvider = StreamProvider.family<int, String>(
  (ref, userId) {
    final service = ref.watch(enhancedNotificationServiceProvider);
    return service.getUnreadNotificationCount(userId);
  },
);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final notificationService = ref.watch(enhancedNotificationServiceProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(
          child: Text('Please log in to view notifications'),
        ),
      );
    }

    final notificationsAsync = ref.watch(enhancedUserNotificationsProvider(user.uid));
    final unreadCountAsync = ref.watch(enhancedUnreadCountProvider(user.uid));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          // Show "Mark all as read" button if there are unread notifications
          unreadCountAsync.when(
            data: (count) => count > 0
                ? TextButton.icon(
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark all read'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
                    ),
                    onPressed: () => _markAllAsRead(user.uid, notificationService),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).appBarTheme.iconTheme?.color),
            onSelected: (value) {
              if (value == 'delete_read') {
                _deleteAllReadNotifications(user.uid, notificationService);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Delete all read'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            itemBuilder: (context, index) {
              return _buildNotificationItem(
                notifications[index],
                notificationService,
                user.uid,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4EFF),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll show up here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    AppNotification notification,
    EnhancedNotificationService notificationService,
    String userId,
  ) {
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        try {
          await notificationService.deleteNotification(userId, notification.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification deleted'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting notification: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            try {
              await notificationService.markAsRead(userId, notification.id);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error marking as read: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
          // TODO: Navigate to relevant screen based on notification.actionUrl
        },
        child: Container(
          color: notification.isRead
              ? Colors.transparent
              : const Color(0xFF5B4EFF).withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Image
              _buildNotificationAvatar(notification, color),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with emoji
                    Row(
                      children: [
                        Text(
                          notification.getIconEmoji(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Message
                    Text(
                      notification.message,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                    ),
                    const SizedBox(height: 4),
                    // Time
                    Text(
                      timeago.format(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B4EFF),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationAvatar(AppNotification notification, Color color) {
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      // Show user/event image if available
      return CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(0.1),
        backgroundImage: NetworkImage(notification.imageUrl!),
      );
    } else {
      // Show icon
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForType(notification.type),
          color: color,
          size: 24,
        ),
      );
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
      case NotificationType.newChat:
        return Icons.message;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.newEventFromOrganizer:
        return Icons.event;
      case NotificationType.eventReminder:
        return Icons.notifications_active;
      case NotificationType.booking:
        return Icons.check_circle;
      case NotificationType.eventUpdate:
        return Icons.update;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
      case NotificationType.newChat:
        return Colors.teal;
      case NotificationType.newFollower:
        return Colors.blue;
      case NotificationType.newEventFromOrganizer:
        return Colors.green;
      case NotificationType.eventReminder:
        return Colors.orange;
      case NotificationType.booking:
        return Colors.purple;
      case NotificationType.eventUpdate:
        return const Color(0xFF5B4EFF);
    }
  }

  Future<void> _markAllAsRead(
      String userId, EnhancedNotificationService service) async {
    try {
      await service.markAllAsRead(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllReadNotifications(
      String userId, EnhancedNotificationService service) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Read Notifications'),
        content: const Text(
          'Are you sure you want to delete all read notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await service.deleteAllReadNotifications(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All read notifications deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
