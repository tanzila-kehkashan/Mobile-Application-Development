import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add bookmark
  Future<void> addBookmark({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'bookmarkedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Bookmark added');
    } catch (e) {
      print('❌ Error adding bookmark: $e');
      rethrow;
    }
  }

  // Remove bookmark
  Future<void> removeBookmark({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(eventId)
          .delete();
      print('✅ Bookmark removed');
    } catch (e) {
      print('❌ Error removing bookmark: $e');
      rethrow;
    }
  }

  // Check if event is bookmarked
  Future<bool> isBookmarked({
    required String userId,
    required String eventId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(eventId)
          .get();

      return doc.exists;
    } catch (e) {
      print('❌ Error checking bookmark status: $e');
      return false;
    }
  }

  // Get user's bookmarked events
  Stream<List<Map<String, dynamic>>> getUserBookmarks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('bookmarkedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> bookmarkedEvents = [];

      for (var doc in snapshot.docs) {
        final eventId = doc.data()['eventId'];
        final eventDoc = await _firestore.collection('events').doc(eventId).get();

        if (eventDoc.exists) {
          final eventData = eventDoc.data() as Map<String, dynamic>;
          bookmarkedEvents.add({
            'id': eventDoc.id,
            ...eventData,
            'bookmarkedAt': doc.data()['bookmarkedAt'],
          });
        }
      }

      return bookmarkedEvents;
    });
  }

  // Toggle bookmark
  Future<bool> toggleBookmark({
    required String userId,
    required String eventId,
  }) async {
    final isCurrentlyBookmarked = await isBookmarked(
      userId: userId,
      eventId: eventId,
    );

    if (isCurrentlyBookmarked) {
      await removeBookmark(userId: userId, eventId: eventId);
      return false;
    } else {
      await addBookmark(userId: userId, eventId: eventId);
      return true;
    }
  }
}
