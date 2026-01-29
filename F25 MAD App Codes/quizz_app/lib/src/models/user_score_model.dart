import 'package:cloud_firestore/cloud_firestore.dart';

class UserScore {
  final String id;
  final String userId;
  final String userName; // Or email if name unavailable
  final int score;
  final int totalQuestions;
  final int quizzesPlayed; // New field
  final DateTime timestamp;

  UserScore({
    required this.id,
    required this.userId,
    required this.userName,
    required this.score,
    required this.totalQuestions,
    this.quizzesPlayed = 0, // Default to 0
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'score': score,
      'totalQuestions': totalQuestions,
      'quizzesPlayed': quizzesPlayed, // Add to map
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create from Firestore
  factory UserScore.fromMap(Map<String, dynamic> map, String docId) {
    return UserScore(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      quizzesPlayed: map['quizzesPlayed'] ?? 0, // Read from map
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
