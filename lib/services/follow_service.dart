import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'enhanced_notification_service.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final EnhancedNotificationService _enhancedNotificationService = EnhancedNotificationService();

  // Follow a user
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to current user's following
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);
      batch.set(followingRef, {
        'userId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Add to target user's followers
      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);
      batch.set(followerRef, {
        'userId': currentUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // Increment current user's following count
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
      });

      // Increment target user's follower count
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followerCount': FieldValue.increment(1),
      });

      await batch.commit();
      print('✅ Successfully followed user');
      
      // Send follower notification with enhanced service
      try {
        // Get current user's display name and profile image
        final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
        final currentUserName = currentUserDoc.data()?['displayName'] ?? 'Someone';
        final currentUserImageUrl = currentUserDoc.data()?['photoURL'] as String?;
        
        await _enhancedNotificationService.sendNewFollowerNotification(
          userId: targetUserId,
          followerName: currentUserName,
          followerId: currentUserId,
          followerImageUrl: currentUserImageUrl,
        );
      } catch (e) {
        print('⚠️ Error sending follower notification: $e');
        // Don't fail the follow action if notification fails
      }
    } catch (e) {
      print('❌ Error following user: $e');
      rethrow;
    }
  }

  // Unfollow a user
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from current user's following
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId);
      batch.delete(followingRef);

      // Remove from target user's followers
      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId);
      batch.delete(followerRef);

      // Decrement current user's following count
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });

      // Decrement target user's follower count
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followerCount': FieldValue.increment(-1),
      });

      await batch.commit();
      print('✅ Successfully unfollowed user');
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  // Check if current user is following target user
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      print('❌ Error checking follow status: $e');
      return false;
    }
  }

  // Get followers list
  Stream<List<Map<String, dynamic>>> getFollowers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> followers = [];
      
      for (var doc in snapshot.docs) {
        final followerId = doc.data()['userId'];
        final userDoc = await _firestore.collection('users').doc(followerId).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          followers.add({
            'userId': followerId,
            'displayName': userData['displayName'] ?? '',
            'photoURL': userData['photoURL'] ?? '',
            'followedAt': doc.data()['followedAt'],
          });
        }
      }
      
      return followers;
    });
  }

  // Get following list
  Stream<List<Map<String, dynamic>>> getFollowing(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> following = [];
      
      for (var doc in snapshot.docs) {
        final followingId = doc.data()['userId'];
        final userDoc = await _firestore.collection('users').doc(followingId).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          following.add({
            'userId': followingId,
            'displayName': userData['displayName'] ?? '',
            'photoURL': userData['photoURL'] ?? '',
            'followedAt': doc.data()['followedAt'],
          });
        }
      }
      
      return following;
    });
  }

  // Get follower count
  Future<int> getFollowerCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return (userDoc.data()?['followerCount'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting follower count: $e');
      return 0;
    }
  }

  // Get following count
  Future<int> getFollowingCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return (userDoc.data()?['followingCount'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting following count: $e');
      return 0;
    }
  }
}
