import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a chat message
class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  /// Create MessageModel from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  /// Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  /// Check if message is from current user
  bool isFromUser(String userId) => senderId == userId;
}
