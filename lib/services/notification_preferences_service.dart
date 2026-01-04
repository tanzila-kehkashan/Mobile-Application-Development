import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Default notification preferences
  static const Map<String, bool> _defaultPreferences = {
    'pushNotifications': true,
    'eventNotifications': true,
    'socialNotifications': true,
    'bookingNotifications': true,
    'messageNotifications': true,
  };
  
  // Save notification preferences to Firestore
  Future<void> savePreferences(String userId, Map<String, bool> prefs) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(prefs, SetOptions(merge: true));
      print('✅ Notification preferences saved');
    } catch (e) {
      print('❌ Error saving notification preferences: $e');
      rethrow;
    }
  }
  
  // Get notification preferences from Firestore
  Stream<Map<String, bool>> getPreferences(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        // Return default preferences if none exist
        return Map<String, bool>.from(_defaultPreferences);
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return {
        'pushNotifications': data['pushNotifications'] ?? true,
        'eventNotifications': data['eventNotifications'] ?? true,
        'socialNotifications': data['socialNotifications'] ?? true,
        'bookingNotifications': data['bookingNotifications'] ?? true,
        'messageNotifications': data['messageNotifications'] ?? true,
      };
    });
  }
  
  // Get preferences as Future (one-time read)
  Future<Map<String, bool>> getPreferencesOnce(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();
      
      if (!doc.exists) {
        // Return default preferences if none exist
        return Map<String, bool>.from(_defaultPreferences);
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return {
        'pushNotifications': data['pushNotifications'] ?? true,
        'eventNotifications': data['eventNotifications'] ?? true,
        'socialNotifications': data['socialNotifications'] ?? true,
        'bookingNotifications': data['bookingNotifications'] ?? true,
        'messageNotifications': data['messageNotifications'] ?? true,
      };
    } catch (e) {
      print('❌ Error getting notification preferences: $e');
      // Return defaults on error
      return Map<String, bool>.from(_defaultPreferences);
    }
  }
}
