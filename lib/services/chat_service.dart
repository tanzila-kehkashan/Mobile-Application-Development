import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'enhanced_notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final EnhancedNotificationService _enhancedNotificationService = EnhancedNotificationService();

  // Get or create chat room between two users
  Future<String> getOrCreateChatRoom(String currentUserId, String otherUserId,
      String currentUserName, String otherUserName) async {
    try {
      // Create a consistent chat ID (alphabetically sorted)
      final participants = [currentUserId, otherUserId].. sort();
      final chatId = participants.join('_');

      final chatDoc = await _firestore. collection('chats'). doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat room
        await _firestore.collection('chats').doc(chatId).set({
          'participants': participants,
          'participantDetails': {
            currentUserId: {'name': currentUserName},
            otherUserId: {'name': otherUserName},
          },
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {currentUserId: 0, otherUserId: 0},
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return chatId;
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    try {
      // Add message to messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'imageUrl': imageUrl,
      });

      // Update chat room's last message
      final chatDoc = await _firestore. collection('chats').doc(chatId).get();
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);

      // Increment unread count for the other user
      final otherUserId = participants.firstWhere((id) => id != senderId);
      final currentUnreadCount = Map<String, dynamic>.from(chatDoc.data()?['unreadCount'] ?? {});
      currentUnreadCount[otherUserId] = (currentUnreadCount[otherUserId] ?? 0) + 1;

      await _firestore. collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': currentUnreadCount,
      });
      
      // Send message notification with enhanced service
      try {
        // Get sender's profile image
        final senderDoc = await _firestore.collection('users').doc(senderId).get();
        final senderImageUrl = senderDoc.data()?['photoURL'] as String?;
        
        await _enhancedNotificationService.sendNewMessageNotification(
          recipientUserId: otherUserId,
          senderName: senderName,
          senderId: senderId,
          messagePreview: text,
          chatId: chatId,
          senderImageUrl: senderImageUrl,
        );
      } catch (e) {
        print('⚠️ Error sending message notification: $e');
        // Don't fail message send if notification fails
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream for a chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        . doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs. map((doc) => ChatMessage.fromFirestore(doc)). toList();
    });
  }

  // ✅ FIXED: Get user's chat rooms (client-side sorting to avoid composite index)
  Stream<List<ChatRoom>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        . snapshots()
        .map((snapshot) {
      // Convert to ChatRoom objects
      final chatRooms = snapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .toList();

      // Sort client-side by lastMessageTime (descending)
      chatRooms.sort((a, b) => b.lastMessageTime.compareTo(a. lastMessageTime));

      return chatRooms;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final chatDoc = await _firestore.collection('chats'). doc(chatId).get();
      final unreadCount = Map<String, dynamic>.from(chatDoc.data()?['unreadCount'] ?? {});
      unreadCount[userId] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });

      // Mark individual messages as read
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          . get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId, String userId) async {
    try {
      // Delete all messages
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete chat room
      await _firestore. collection('chats').doc(chatId).delete();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }
}