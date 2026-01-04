import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';

/// Comprehensive notification service as singleton
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize Firebase Cloud Messaging and Flutter Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional notification permission');
      } else {
        print('❌ User declined or has not accepted notification permission');
      }

      // Initialize local notifications with multiple channels
      await _initializeLocalNotifications();

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        print('📱 FCM Token: $token');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      _messaging.getInitialMessage().then((message) {
        if (message != null) {
          _handleNotificationTap(message);
        }
      });

      _isInitialized = true;
      print('✅ Enhanced Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Initialize local notifications with multiple Android channels
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings with multiple channels
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleLocalNotificationTap(response);
      },
    );

    // Create Android notification channels
    await _createNotificationChannels();
  }

  /// Create multiple Android notification channels
  Future<void> _createNotificationChannels() async {
    // Chat notifications channel (high importance)
    const chatChannel = AndroidNotificationChannel(
      'chat_notifications',
      'Chat Notifications',
      description: 'Notifications for new messages and chats',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Follow notifications channel (default importance)
    const followChannel = AndroidNotificationChannel(
      'follow_notifications',
      'Follow Notifications',
      description: 'Notifications when someone follows you',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    // Event notifications channel (high importance)
    const eventChannel = AndroidNotificationChannel(
      'event_notifications',
      'Event Notifications',
      description: 'Notifications for new events from organizers you follow',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Reminder notifications channel (max importance)
    const reminderChannel = AndroidNotificationChannel(
      'reminder_notifications',
      'Event Reminders',
      description: 'Important reminders for upcoming events',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Register channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(chatChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(followChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Got a message in foreground: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        channelId: message.data['channelId'] ?? 'event_notifications',
        payload: message.data['payload'],
      );
    }
  }

  /// Handle notification tap from system tray
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.notification?.title}');
    // TODO: Navigate to relevant screen based on message.data
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // TODO: Navigate to relevant screen based on payload
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: _getImportance(channelId),
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get channel name from ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'chat_notifications':
        return 'Chat Notifications';
      case 'follow_notifications':
        return 'Follow Notifications';
      case 'event_notifications':
        return 'Event Notifications';
      case 'reminder_notifications':
        return 'Event Reminders';
      default:
        return 'Notifications';
    }
  }

  /// Get importance from channel ID
  Importance _getImportance(String channelId) {
    switch (channelId) {
      case 'reminder_notifications':
        return Importance.max;
      case 'chat_notifications':
      case 'event_notifications':
        return Importance.high;
      case 'follow_notifications':
      default:
        return Importance.defaultImportance;
    }
  }

  /// Save FCM token to user document
  Future<void> saveFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token saved for user $userId');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ============================================================================
  // NOTIFICATION CREATION METHODS
  // ============================================================================

  /// Send notification when user receives a new message
  Future<void> sendNewMessageNotification({
    required String recipientUserId,
    required String senderName,
    required String senderId,
    required String messagePreview,
    required String chatId,
    String? senderImageUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: recipientUserId,
        type: NotificationType.newMessage,
        title: 'New Message from $senderName',
        message: messagePreview,
        createdAt: DateTime.now(),
        isRead: false,
        imageUrl: senderImageUrl,
        data: {
          'senderId': senderId,
          'chatId': chatId,
        },
        actionUrl: '/chat/$chatId',
      );

      await _createNotificationInFirestore(notification);

      // Show system notification
      await _showLocalNotification(
        title: notification.title,
        body: notification.message,
        channelId: 'chat_notifications',
        payload: 'chat:$chatId',
      );

      print('✅ New message notification sent to $recipientUserId');
    } catch (e) {
      print('❌ Error sending new message notification: $e');
    }
  }

  /// Send notification when someone starts a new chat
  Future<void> sendNewChatNotification({
    required String recipientUserId,
    required String senderName,
    required String senderId,
    required String chatId,
    String? senderImageUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: recipientUserId,
        type: NotificationType.newChat,
        title: 'New Chat',
        message: '$senderName started a conversation with you',
        createdAt: DateTime.now(),
        isRead: false,
        imageUrl: senderImageUrl,
        data: {
          'senderId': senderId,
          'chatId': chatId,
        },
        actionUrl: '/chat/$chatId',
      );

      await _createNotificationInFirestore(notification);

      // Show system notification
      await _showLocalNotification(
        title: notification.title,
        body: notification.message,
        channelId: 'chat_notifications',
        payload: 'chat:$chatId',
      );

      print('✅ New chat notification sent to $recipientUserId');
    } catch (e) {
      print('❌ Error sending new chat notification: $e');
    }
  }

  /// Send notification when someone follows the user
  Future<void> sendNewFollowerNotification({
    required String userId,
    required String followerName,
    required String followerId,
    String? followerImageUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: userId,
        type: NotificationType.newFollower,
        title: 'New Follower',
        message: '$followerName started following you',
        createdAt: DateTime.now(),
        isRead: false,
        imageUrl: followerImageUrl,
        data: {
          'followerId': followerId,
        },
        actionUrl: '/profile/$followerId',
      );

      await _createNotificationInFirestore(notification);

      // Show system notification
      await _showLocalNotification(
        title: notification.title,
        body: notification.message,
        channelId: 'follow_notifications',
        payload: 'profile:$followerId',
      );

      print('✅ New follower notification sent to $userId');
    } catch (e) {
      print('❌ Error sending new follower notification: $e');
    }
  }

  /// Send notification to all followers when organizer creates a new event
  Future<void> sendNewEventFromOrganizerNotification({
    required String organizerId,
    required String organizerName,
    required String eventId,
    required String eventTitle,
    String? eventImageUrl,
  }) async {
    try {
      // Get organizer's followers
      final followersSnapshot = await _firestore
          .collection('users')
          .doc(organizerId)
          .collection('followers')
          .get();

      // Send notification to each follower
      for (var followerDoc in followersSnapshot.docs) {
        final followerId = followerDoc.data()['userId'];
        if (followerId != null) {
          final notification = AppNotification(
            id: '',
            userId: followerId,
            type: NotificationType.newEventFromOrganizer,
            title: 'New Event',
            message: '$organizerName created a new event: $eventTitle',
            createdAt: DateTime.now(),
            isRead: false,
            imageUrl: eventImageUrl,
            data: {
              'eventId': eventId,
              'organizerId': organizerId,
            },
            actionUrl: '/event/$eventId',
          );

          await _createNotificationInFirestore(notification);

          // Show system notification
          await _showLocalNotification(
            title: notification.title,
            body: notification.message,
            channelId: 'event_notifications',
            payload: 'event:$eventId',
          );
        }
      }

      print('✅ New event notifications sent to ${followersSnapshot.docs.length} followers');
    } catch (e) {
      print('❌ Error sending new event notifications: $e');
    }
  }

  /// Send event reminder notification 1 day before event
  Future<void> sendEventReminderNotification({
    required String userId,
    required String eventId,
    required String eventTitle,
    String? eventImageUrl,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: userId,
        type: NotificationType.eventReminder,
        title: 'Event Reminder',
        message: 'Your event "$eventTitle" is starting in 24 hours!',
        createdAt: DateTime.now(),
        isRead: false,
        imageUrl: eventImageUrl,
        data: {
          'eventId': eventId,
        },
        actionUrl: '/event/$eventId',
      );

      await _createNotificationInFirestore(notification);

      // Show system notification
      await _showLocalNotification(
        title: notification.title,
        body: notification.message,
        channelId: 'reminder_notifications',
        payload: 'event:$eventId',
      );

      print('✅ Event reminder notification sent to $userId');
    } catch (e) {
      print('❌ Error sending event reminder notification: $e');
    }
  }

  // ============================================================================
  // NOTIFICATION MANAGEMENT METHODS
  // ============================================================================

  /// Get user's notifications as a stream
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  /// Get unread notification count as a stream
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark single notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete single notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      print('✅ Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('✅ All read notifications deleted');
    } catch (e) {
      print('❌ Error deleting read notifications: $e');
      rethrow;
    }
  }

  /// Schedule event reminder in Firestore for 1 day before event
  Future<void> scheduleEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
    String? eventImageUrl,
  }) async {
    try {
      // Calculate reminder time (24 hours before event)
      final reminderTime = eventDate.subtract(const Duration(hours: 24));

      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await _firestore.collection('scheduled_reminders').add({
          'userId': userId,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'eventDate': Timestamp.fromDate(eventDate),
          'reminderTime': Timestamp.fromDate(reminderTime),
          'eventImageUrl': eventImageUrl,
          'sent': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Event reminder scheduled for ${reminderTime.toIso8601String()}');
      } else {
        print('⚠️ Event is less than 24 hours away, reminder not scheduled');
      }
    } catch (e) {
      print('❌ Error scheduling event reminder: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Create notification in Firestore under user's subcollection
  Future<void> _createNotificationInFirestore(AppNotification notification) async {
    try {
      await _firestore
          .collection('users')
          .doc(notification.userId)
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      print('❌ Error creating notification in Firestore: $e');
      rethrow;
    }
  }
}
