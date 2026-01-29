import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistory {
  final String id;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;

  QuizHistory({
    required this.id,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory QuizHistory.fromMap(Map<String, dynamic> map, String docId) {
    return QuizHistory(
      id: docId,
      quizTitle: map['quizTitle'] ?? 'Unknown Quiz',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
