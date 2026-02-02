import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a comment on a post
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  /// Create CommentModel from Firestore document
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      authorPhotoUrl: map['authorPhotoUrl'],
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert CommentModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
