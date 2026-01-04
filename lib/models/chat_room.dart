import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants; // User IDs
  final Map<String, dynamic> participantDetails; // {userId: {name, avatar, etc}}
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // {userId: count}

  ChatRoom({
    required this.id,
    required this. participants,
    required this.participantDetails,
    required this. lastMessage,
    required this. lastMessageTime,
    required this.unreadCount,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantDetails: Map<String, dynamic>.from(data['participantDetails'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantDetails': participantDetails,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
    };
  }
}