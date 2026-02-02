import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a post in the feed
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String? imageUrl;
  final String? caption;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    this.imageUrl,
    this.caption,
    this.likes = const [],
    this.commentCount = 0,
    required this.createdAt,
  });

  /// Create PostModel from Firestore document
  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      authorPhotoUrl: map['authorPhotoUrl'],
      imageUrl: map['imageUrl'],
      caption: map['caption'],
      likes: List<String>.from(map['likes'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert PostModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Check if user has liked this post
  bool isLikedBy(String userId) => likes.contains(userId);

  /// Get like count
  int get likeCount => likes.length;

  /// Create copy with updated likes
  PostModel copyWithLike(String userId, bool isLiked) {
    final newLikes = List<String>.from(likes);
    if (isLiked) {
      newLikes.add(userId);
    } else {
      newLikes.remove(userId);
    }
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      imageUrl: imageUrl,
      caption: caption,
      likes: newLikes,
      commentCount: commentCount,
      createdAt: createdAt,
    );
  }
}
