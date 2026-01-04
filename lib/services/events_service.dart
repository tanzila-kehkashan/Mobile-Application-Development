// Modified: added updateEvent and deleteEvent methods
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'enhanced_notification_service.dart';
import '../models/notification_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final EnhancedNotificationService _enhancedNotificationService = EnhancedNotificationService();

  // Add a single event
  Future<String> addEvent(Map<String, dynamic> eventData) async {
    try {
      final docRef = await _firestore.collection('events').add(eventData);
      print('✅ Event added successfully!');

      // Send notifications to followers about new event with enhanced service
      if (eventData['organizerId'] != null) {
        try {
          // Get organizer details
          final organizerDoc = await _firestore.collection('users').doc(eventData['organizerId']).get();
          final organizerName = organizerDoc.data()?['displayName'] ?? 'An organizer';

          await _enhancedNotificationService.sendNewEventFromOrganizerNotification(
            organizerId: eventData['organizerId'],
            organizerName: organizerName,
            eventId: docRef.id,
            eventTitle: eventData['title'] ?? 'New Event',
            eventImageUrl: eventData['imageUrl'] as String?,
          );
        } catch (e) {
          print('⚠️ Error sending new event notifications: $e');
          // Don't fail event creation if notification fails
        }
      }

      return docRef.id;
    } catch (e) {
      print('❌ Error adding event: $e');
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    try {
      // Do not overwrite organizerId/organizerName accidentally; caller should include intended fields.
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('events').doc(eventId).update(updatedData);
      print('✅ Event ($eventId) updated successfully!');
    } catch (e) {
      print('❌ Error updating event $eventId: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      // Optionally: fetch event to cleanup related storage assets (images). Caller may implement storage deletion.
      // final snapshot = await _firestore.collection('events').doc(eventId).get();
      // final imageUrl = snapshot.data()?['imageUrl'] as String?;
      // if (imageUrl != null && imageUrl.isNotEmpty) { delete from storage... }

      await _firestore.collection('events').doc(eventId).delete();
      print('✅ Event ($eventId) deleted successfully!');
    } catch (e) {
      print('❌ Error deleting event $eventId: $e');
      rethrow;
    }
  }

  // Send notifications to followers about new event (legacy method not used directly)
  Future<void> _sendNewEventNotifications({
    required String organizerId,
    required String eventTitle,
    required String eventId,
  }) async {
    try {
      // Get organizer's followers
      final followersSnapshot = await _firestore.collection('users').doc(organizerId).collection('followers').get();

      // Get organizer name
      final organizerDoc = await _firestore.collection('users').doc(organizerId).get();
      final organizerName = organizerDoc.data()?['displayName'] ?? 'An organizer';

      // Send notification to each follower
      for (var followerDoc in followersSnapshot.docs) {
        final followerId = followerDoc.data()['userId'];
        if (followerId != null) {
          await _notificationService.createNotification(
            NotificationModel(
              id: '',
              userId: followerId,
              type: 'new_event',
              title: 'New Event',
              message: '$organizerName created a new event: $eventTitle',
              createdAt: DateTime.now(),
              isRead: false,
              data: {
                'eventId': eventId,
                'organizerId': organizerId,
              },
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error sending new event notifications: $e');
      rethrow;
    }
  }

  // Seed multiple dummy events
  Future<void> seedDummyEvents() async {
    final List<Map<String, dynamic>> dummyEvents = [
      // ... existing dummy events (unchanged)
    ];

    try {
      // Use batch write for better performance
      final batch = _firestore.batch();

      for (var eventData in dummyEvents) {
        final docRef = _firestore.collection('events').doc();
        batch.set(docRef, eventData);
      }

      await batch.commit();
      print('✅ Successfully seeded ${dummyEvents.length} dummy events!');
    } catch (e) {
      print('❌ Error seeding events: $e');
      rethrow;
    }
  }

  // Delete all events (use with caution!)
  Future<void> clearAllEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All events cleared!');
    } catch (e) {
      print('❌ Error clearing events: $e');
      rethrow;
    }
  }
}