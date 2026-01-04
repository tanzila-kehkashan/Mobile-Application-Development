import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for different notification types
enum NotificationType {
  newMessage,
  newChat,
  newFollower,
  newEventFromOrganizer,
  eventReminder,
  booking,
  eventUpdate,
}

/// Enhanced notification model with proper typing
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  /// Create AppNotification from Firestore document
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: _notificationTypeFromString(data['type'] ?? ''),
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      data: data['data'] as Map<String, dynamic>?,
      imageUrl: data['imageUrl'] as String?,
      actionUrl: data['actionUrl'] as String?,
    );
  }

  /// Convert AppNotification to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': _notificationTypeToString(type),
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Get icon emoji based on notification type
  String getIconEmoji() {
    switch (type) {
      case NotificationType.newMessage:
      case NotificationType.newChat:
        return '💬';
      case NotificationType.newFollower:
        return '👤';
      case NotificationType.newEventFromOrganizer:
        return '🎉';
      case NotificationType.eventReminder:
        return '⏰';
      case NotificationType.booking:
        return '🎫';
      case NotificationType.eventUpdate:
        return '📢';
    }
  }

  /// Copy with method for creating modified copies
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Convert string to NotificationType
  static NotificationType _notificationTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'newmessage':
      case 'new_message':
      case 'message':
        return NotificationType.newMessage;
      case 'newchat':
      case 'new_chat':
        return NotificationType.newChat;
      case 'newfollower':
      case 'new_follower':
      case 'follower':
        return NotificationType.newFollower;
      case 'neweventfromorganizer':
      case 'new_event_from_organizer':
      case 'new_event':
        return NotificationType.newEventFromOrganizer;
      case 'eventreminder':
      case 'event_reminder':
        return NotificationType.eventReminder;
      case 'booking':
        return NotificationType.booking;
      case 'eventupdate':
      case 'event_update':
        return NotificationType.eventUpdate;
      default:
        return NotificationType.eventUpdate; // default fallback
    }
  }

  /// Convert NotificationType to string
  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.newChat:
        return 'new_chat';
      case NotificationType.newFollower:
        return 'new_follower';
      case NotificationType.newEventFromOrganizer:
        return 'new_event_from_organizer';
      case NotificationType.eventReminder:
        return 'event_reminder';
      case NotificationType.booking:
        return 'booking';
      case NotificationType.eventUpdate:
        return 'event_update';
    }
  }
}
