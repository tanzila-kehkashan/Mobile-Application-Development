import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/models/message_model.dart';
import 'package:nexus/models/conversation_model.dart';

/// Service class for real-time chat functionality
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all conversations for a user
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid composite index requirement
          conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
          return conversations;
        });
  }

  /// Get messages for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? imageUrl,
  }) async {
    final message = MessageModel(
      id: '',
      senderId: senderId,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add message to subcollection
    await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toMap());

    // Update conversation's last message
    await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': content.isNotEmpty ? content : '📷 Image',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
  }

  /// Create or get existing conversation between two users
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    String? user1PhotoUrl,
    String? user2PhotoUrl,
  }) async {
    // Check if conversation already exists
    final existing = await _db
        .collection('conversations')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in existing.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // Create new conversation
    final conversation = ConversationModel(
      id: '',
      participants: [userId1, userId2],
      participantNames: {userId1: user1Name, userId2: user2Name},
      participantPhotos: {
        if (user1PhotoUrl != null) userId1: user1PhotoUrl,
        if (user2PhotoUrl != null) userId2: user2PhotoUrl,
      },
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      lastSenderId: '',
    );

    final docRef = await _db.collection('conversations').add(conversation.toMap());
    return docRef.id;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String readerId) async {
    final messages = await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: readerId)
        .get();

    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Get unread message count for a user
  Stream<int> getUnreadCount(String conversationId, String userId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages first
    final messages = await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();

    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('conversations').doc(conversationId));
    await batch.commit();
  }
}
