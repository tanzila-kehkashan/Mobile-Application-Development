import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/follow_service.dart';

// Follow Service Provider
final followServiceProvider = Provider<FollowService>((ref) {
  return FollowService();
});

// Followers Stream Provider
final followersProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) {
    final service = ref.watch(followServiceProvider);
    return service.getFollowers(userId);
  },
);

// Following Stream Provider
final followingProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) {
    final service = ref.watch(followServiceProvider);
    return service.getFollowing(userId);
  },
);

// Is Following Provider
final isFollowingProvider = FutureProvider.family<bool, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(followServiceProvider);
    return await service.isFollowing(
      currentUserId: params['currentUserId']!,
      targetUserId: params['targetUserId']!,
    );
  },
);

// Follower Count Provider
final followerCountProvider = FutureProvider.family<int, String>(
  (ref, userId) async {
    final service = ref.watch(followServiceProvider);
    return await service.getFollowerCount(userId);
  },
);

// Following Count Provider
final followingCountProvider = FutureProvider.family<int, String>(
  (ref, userId) async {
    final service = ref.watch(followServiceProvider);
    return await service.getFollowingCount(userId);
  },
);
