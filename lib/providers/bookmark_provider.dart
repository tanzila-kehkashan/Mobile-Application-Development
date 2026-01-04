import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bookmark_service.dart';

// Bookmark Service Provider
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

// User Bookmarks Stream Provider
final userBookmarksProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) {
    final service = ref.watch(bookmarkServiceProvider);
    return service.getUserBookmarks(userId);
  },
);

// Is Bookmarked Provider
final isBookmarkedProvider = FutureProvider.family<bool, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(bookmarkServiceProvider);
    return await service.isBookmarked(
      userId: params['userId']!,
      eventId: params['eventId']!,
    );
  },
);
