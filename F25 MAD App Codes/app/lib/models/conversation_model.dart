import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a conversation between users
class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastSenderId;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.participantPhotos = const {},
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
  });

  /// Create ConversationModel from Firestore document
  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantPhotos: Map<String, String>.from(map['participantPhotos'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSenderId: map['lastSenderId'] ?? '',
    );
  }

  /// Convert ConversationModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastSenderId': lastSenderId,
    };
  }

  /// Get the other participant's ID (for 1:1 chats)
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get the other participant's name
  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Get the other participant's photo URL
  String? getOtherParticipantPhoto(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantPhotos[otherId];
  }
}
