import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize FCM
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Update token in Firestore if user is logged in
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Save FCM token to user document
  Future<void> saveFCMToken(String userId) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message in foreground: ${message.notification?.title}');
    
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
      );
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  // Create notification in Firestore
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .add(notification.toMap());
      print('✅ Notification created');
    } catch (e) {
      print('❌ Error creating notification: $e');
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    // 1. We query only the collection without combined filters/ordering
    return _firestore
        .collection('notifications')
        .snapshots() // Get all notifications (real-time)
        .map((snapshot) {

      // 2. Perform filtering and sorting client-side in Dart
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((notification) => notification.userId == userId) // Client-side filter
          .toList();

      // 3. Sort by date descending (Newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  // Send follower notification
  Future<void> sendFollowerNotification({
    required String userId,
    required String followerName,
    required String followerId,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: 'follower',
      title: 'New Follower',
      message: '$followerName started following you',
      createdAt: DateTime.now(),
      isRead: false,
      data: {'followerId': followerId},
    );
    await createNotification(notification);
  }

  // Send booking confirmation notification
  Future<void> sendBookingConfirmation({
    required String userId,
    required String eventTitle,
    required String bookingId,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: 'booking',
      title: 'Booking Confirmed',
      message: 'Your booking for $eventTitle is confirmed',
      createdAt: DateTime.now(),
      isRead: false,
      data: {'bookingId': bookingId},
    );
    await createNotification(notification);
  }

  // Send event reminder notification
  Future<void> sendEventReminder({
    required String userId,
    required String eventTitle,
    required String eventId,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: 'event_reminder',
      title: 'Event Reminder',
      message: 'Your event "$eventTitle" is starting in 24 hours',
      createdAt: DateTime.now(),
      isRead: false,
      data: {'eventId': eventId},
    );
    await createNotification(notification);
  }
}
