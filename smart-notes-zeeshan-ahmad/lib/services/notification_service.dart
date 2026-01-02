import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  
  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    final notifications = notificationsJson
        .map((json) => NotificationModel.fromJson(jsonDecode(json)))
        .toList();
    
    // Sort by timestamp, newest first
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return notifications;
  }
  
  // Add a new notification
  Future<void> addNotification({
    required String title,
    required String description,
    String iconType = 'document',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      timestamp: DateTime.now(),
      iconType: iconType,
    );
    
    notificationsJson.add(jsonEncode(notification.toJson()));
    
    // Keep only last 50 notifications
    if (notificationsJson.length > 50) {
      notificationsJson.removeAt(0);
    }
    
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }
  
  // Clear all notifications
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
  
  // Mark notification as read (optional)
  Future<void> markAsRead(String id) async {
    // This could be implemented if needed
  }
}
