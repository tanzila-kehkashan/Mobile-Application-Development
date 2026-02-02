import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/job_model.dart';
import 'package:nexus/models/event_model.dart';
import 'package:nexus/models/comment_model.dart';

/// Service class for Firestore database operations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ USER OPERATIONS ============

  /// Create a new user profile in Firestore
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).update(data);
  }

  /// Stream of user data
  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Search users by display name
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _db
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Get all users (for chat list)
  Future<List<UserModel>> getAllUsers({String? excludeUid}) async {
    Query<Map<String, dynamic>> query = _db.collection('users').limit(50);
    
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((user) => user.uid != excludeUid)
        .toList();
  }

  /// Update online status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _db.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }

  // ============ POST OPERATIONS ============

  /// Create a new post
  Future<String> createPost(PostModel post) async {
    final docRef = await _db.collection('posts').add(post.toMap());
    return docRef.id;
  }

  /// Get posts stream (ordered by date, newest first)
  Stream<List<PostModel>> postsStream() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get single post
  Future<PostModel?> getPost(String postId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    if (doc.exists && doc.data() != null) {
      return PostModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    await _db.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  /// Get user's posts
  Stream<List<PostModel>> userPostsStream(String userId) {
    return _db
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Search posts by caption
  Future<List<PostModel>> searchPosts(String query) async {
    if (query.isEmpty) return [];
    
    // Get all posts and filter client-side (Firestore doesn't support full-text search)
    final snapshot = await _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data(), doc.id))
        .where((post) => 
            post.caption?.toLowerCase().contains(lowerQuery) == true ||
            post.authorName.toLowerCase().contains(lowerQuery))
        .take(20)
        .toList();
  }

  // ============ COMMENT OPERATIONS ============

  /// Add a comment to a post
  Future<String> addComment(CommentModel comment) async {
    final batch = _db.batch();
    
    // Add the comment
    final commentRef = _db.collection('comments').doc();
    batch.set(commentRef, comment.toMap());
    
    // Update comment count on post
    final postRef = _db.collection('posts').doc(comment.postId);
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
    });
    
    await batch.commit();
    return commentRef.id;
  }

  /// Get comments for a post
  Stream<List<CommentModel>> commentsStream(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid composite index requirement
          comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return comments;
        });
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    final batch = _db.batch();
    
    batch.delete(_db.collection('comments').doc(commentId));
    batch.update(_db.collection('posts').doc(postId), {
      'commentCount': FieldValue.increment(-1),
    });
    
    await batch.commit();
  }

  // ============ REPORT OPERATIONS ============

  /// Report a post
  Future<void> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
  }) async {
    await _db.collection('reports').add({
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'type': 'post',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // ============ FOLLOW OPERATIONS ============

  /// Follow a user
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _db.batch();
    
    // Add to current user's following
    batch.update(_db.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayUnion([targetUserId]),
    });
    
    // Add to target user's followers
    batch.update(_db.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayUnion([currentUserId]),
    });
    
    await batch.commit();
  }

  /// Unfollow a user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _db.batch();
    
    batch.update(_db.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayRemove([targetUserId]),
    });
    
    batch.update(_db.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
    
    await batch.commit();
  }

  // ============ JOB OPERATIONS ============

  /// Create a new job
  Future<String> createJob(JobModel job) async {
    final docRef = await _db.collection('jobs').add(job.toMap());
    return docRef.id;
  }

  /// Get jobs stream (ordered by date, newest first)
  Stream<List<JobModel>> jobsStream() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get single job
  Future<JobModel?> getJob(String jobId) async {
    final doc = await _db.collection('jobs').doc(jobId).get();
    if (doc.exists && doc.data() != null) {
      return JobModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }

  /// Get user's jobs
  Stream<List<JobModel>> userJobsStream(String userId) {
    return _db
        .collection('jobs')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get recent jobs (for notifications)
  Future<List<JobModel>> getRecentJobs({int limit = 10}) async {
    final snapshot = await _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => JobModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ============ EVENT OPERATIONS ============

  /// Create a new event
  Future<String> createEvent(EventModel event) async {
    final docRef = await _db.collection('events').add(event.toMap());
    return docRef.id;
  }

  /// Get events stream (ordered by event date)
  Stream<List<EventModel>> eventsStream() {
    return _db
        .collection('events')
        .orderBy('eventDate', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get events for a specific month
  Stream<List<EventModel>> eventsForMonthStream(int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    return _db
        .collection('events')
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get single event
  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (doc.exists && doc.data() != null) {
      return EventModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  /// Get user's events
  Stream<List<EventModel>> userEventsStream(String userId) {
    return _db
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get recent events (for notifications)
  Future<List<EventModel>> getRecentEvents({int limit = 10}) async {
    final snapshot = await _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Search events by title
  Future<List<EventModel>> searchEvents(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _db
        .collection('events')
        .orderBy('eventDate', descending: false)
        .limit(100)
        .get();

    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .where((event) => 
            event.title.toLowerCase().contains(lowerQuery) ||
            (event.description?.toLowerCase().contains(lowerQuery) ?? false))
        .take(20)
        .toList();
  }

  // ============ ACCOUNT DELETION ============

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String userId) async {
    final batch = _db.batch();

    // Delete user's posts
    final posts = await _db
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .get();
    for (var doc in posts.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's comments
    final comments = await _db
        .collection('comments')
        .where('authorId', isEqualTo: userId)
        .get();
    for (var doc in comments.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's jobs
    final jobs = await _db
        .collection('jobs')
        .where('postedBy', isEqualTo: userId)
        .get();
    for (var doc in jobs.docs) {
      batch.delete(doc.reference);
    }

    // Delete user's events
    final events = await _db
        .collection('events')
        .where('createdBy', isEqualTo: userId)
        .get();
    for (var doc in events.docs) {
      batch.delete(doc.reference);
    }

    // Commit first batch
    await batch.commit();

    // Delete conversations (separate batch due to size limits)
    final conversations = await _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .get();
    for (var conv in conversations.docs) {
      // Delete messages in conversation
      final messages = await conv.reference.collection('messages').get();
      final msgBatch = _db.batch();
      for (var msg in messages.docs) {
        msgBatch.delete(msg.reference);
      }
      await msgBatch.commit();
      // Delete conversation
      await conv.reference.delete();
    }

    // Remove user from other users' followers/following lists
    final user = await getUser(userId);
    if (user != null) {
      // Remove from followers' following lists
      for (var followerId in user.followers) {
        await _db.collection('users').doc(followerId).update({
          'following': FieldValue.arrayRemove([userId]),
        });
      }
      // Remove from following's followers lists
      for (var followingId in user.following) {
        await _db.collection('users').doc(followingId).update({
          'followers': FieldValue.arrayRemove([userId]),
        });
      }
    }

    // Finally delete user document
    await _db.collection('users').doc(userId).delete();
  }
}

