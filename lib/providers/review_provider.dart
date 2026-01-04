import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/review_service.dart';
import '../models/review.dart';

// Review Service Provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

// Event Reviews Stream Provider
final eventReviewsProvider = StreamProvider.family<List<Review>, String>(
  (ref, eventId) {
    final service = ref.watch(reviewServiceProvider);
    return service.getEventReviews(eventId);
  },
);

// Event Rating Provider
final eventRatingProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, eventId) async {
    final service = ref.watch(reviewServiceProvider);
    return await service.getEventRating(eventId);
  },
);

// User Review for Event Provider
final userReviewForEventProvider = FutureProvider.family<Review?, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(reviewServiceProvider);
    return await service.getUserReviewForEvent(params['userId']!, params['eventId']!);
  },
);
