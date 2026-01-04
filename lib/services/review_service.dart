import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a review
  Future<void> addReview(Review review) async {
    try {
      await _firestore
          .collection('reviews')
          .add(review.toMap());
      
      // Update event's average rating
      await _updateEventAverageRating(review.eventId);
      
      print('✅ Review added successfully');
    } catch (e) {
      print('❌ Error adding review: $e');
      rethrow;
    }
  }

  // Update a review
  Future<void> updateReview(String reviewId, double rating, String comment) async {
    try {
      final review = await _firestore.collection('reviews').doc(reviewId).get();
      final eventId = review.data()?['eventId'] as String;
      
      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update event's average rating
      await _updateEventAverageRating(eventId);
      
      print('✅ Review updated successfully');
    } catch (e) {
      print('❌ Error updating review: $e');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String eventId) async {
    try {
      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .delete();

      // Update event's average rating
      await _updateEventAverageRating(eventId);
      
      print('✅ Review deleted successfully');
    } catch (e) {
      print('❌ Error deleting review: $e');
      rethrow;
    }
  }

  // Get reviews for an event
  Stream<List<Review>> getEventReviews(String eventId) {
    return _firestore
        .collection('reviews')
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's review for an event (if exists)
  Future<Review?> getUserReviewForEvent(String userId, String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Review.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user review: $e');
      return null;
    }
  }

  // Check if user can review (event has passed)
  Future<bool> canUserReview(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return false;

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final eventDate = (eventData['date'] as Timestamp).toDate();
      
      // User can review if event date has passed
      return eventDate.isBefore(DateTime.now());
    } catch (e) {
      print('❌ Error checking review eligibility: $e');
      return false;
    }
  }

  // Update event's average rating
  Future<void> _updateEventAverageRating(String eventId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        // No reviews, set rating to 0
        await _firestore.collection('events').doc(eventId).update({
          'averageRating': 0.0,
          'reviewCount': 0,
        });
        return;
      }

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
      }

      final averageRating = totalRating / reviewsSnapshot.docs.length;

      await _firestore.collection('events').doc(eventId).update({
        'averageRating': averageRating,
        'reviewCount': reviewsSnapshot.docs.length,
      });

      print('✅ Event average rating updated: $averageRating');
    } catch (e) {
      print('❌ Error updating event average rating: $e');
    }
  }

  // Get average rating for an event
  Future<Map<String, dynamic>> getEventRating(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        return {'averageRating': 0.0, 'reviewCount': 0};
      }

      final data = eventDoc.data() as Map<String, dynamic>;
      return {
        'averageRating': (data['averageRating'] ?? 0.0).toDouble(),
        'reviewCount': data['reviewCount'] ?? 0,
      };
    } catch (e) {
      print('❌ Error getting event rating: $e');
      return {'averageRating': 0.0, 'reviewCount': 0};
    }
  }
}
