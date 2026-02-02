import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'package:quizz_app/src/models/user_score_model.dart';
import 'package:quizz_app/src/models/quiz_history_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all quizzes
  Stream<List<Quiz>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Fetch questions for a specific quiz (assuming subcollection 'questions')
  Stream<List<Question>> getQuestions(String quizId) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new quiz
  Future<String> addQuiz(Map<String, dynamic> quizData) async {
    DocumentReference docRef = await _firestore.collection('quizzes').add(quizData);
    return docRef.id;
  }

  // Add a question to a quiz
  Future<void> addQuestion(String quizId, Map<String, dynamic> questionData) async {
    await _firestore
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .add(questionData);
    
    // Increment questionCount in parent quiz document
    await _firestore.collection('quizzes').doc(quizId).update({
      'questionCount': FieldValue.increment(1)
    });
  }

  // Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  // Delete a question
  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _firestore
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .doc(questionId)
            .delete();

    // Decrement questionCount in parent quiz document
    await _firestore.collection('quizzes').doc(quizId).update({
      'questionCount': FieldValue.increment(-1)
    });
  }

  // Save User Score
  Future<void> saveUserScore(UserScore score) async {
    // Ideally use userId as doc ID to have one score per user, 
    // OR separate ID for log of scores. 
    // For Leaderboard "High Score", using userId as key is better.
    // Let's assume we keep one entry per user and update if higher.

    final userScoreRef = _firestore.collection('scores').doc(score.userId);
    final doc = await userScoreRef.get();

    if (doc.exists) {
      final existingScore = UserScore.fromMap(doc.data()!, doc.id);
      
      // Cumulative Logic (XP System)
      final newTotalScore = existingScore.score + score.score;
      final newTotalQuestions = existingScore.totalQuestions + score.totalQuestions;
      final newQuizzesPlayed = existingScore.quizzesPlayed + 1; // Increment

      await userScoreRef.update({
        'score': newTotalScore,
        'totalQuestions': newTotalQuestions,
        'quizzesPlayed': newQuizzesPlayed, // Update count
        'userName': score.userName, // Keep name synced
        'timestamp': Timestamp.fromDate(score.timestamp), // Update last active
      });
      
    } else {
      // First time playing
      Map<String, dynamic> data = score.toMap();
      data['quizzesPlayed'] = 1; // Initialize to 1
      await userScoreRef.set(data);
    }
  }

  // Get Leaderboard (Top 50)
  Stream<List<UserScore>> getLeaderboard() {
    return _firestore
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserScore.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
  // Update User Name in Leaderboard
  Future<void> updateUserName(String uid, String newName) async {
    final userScoreRef = _firestore.collection('scores').doc(uid);
    final doc = await userScoreRef.get();
    
    if (doc.exists) {
      await userScoreRef.update({'userName': newName});
    }
    // If doc doesn't exist, we don't need to do anything as it will be created with correct name on next score save
  }
  // Save Quiz History
  Future<void> saveQuizHistory(String userId, QuizHistory history) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .add(history.toMap());
  }

  // Get Quiz History (Recent First)
  Stream<List<QuizHistory>> getQuizHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(20) // Limit to last 20
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuizHistory.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Delete Quiz History Item
  Future<void> deleteQuizHistory(String userId, String historyId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(historyId)
        .delete();
  }


  // Sync Quizzes Played Count (Backfill from History)
  Future<void> syncQuizzesPlayedCount(String userId) async {
    final historySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .get(); // Count actual history items

    final historyCount = historySnapshot.size;

    if (historyCount > 0) {
      final userScoreRef = _firestore.collection('scores').doc(userId);
      final userScoreDoc = await userScoreRef.get();

      if (userScoreDoc.exists) {
        final currentCount = userScoreDoc.data()?['quizzesPlayed'] ?? 0;
        // Only update if current is 0 or less than history (bootstrapping)
        if (currentCount == 0 || currentCount < historyCount) {
             await userScoreRef.update({'quizzesPlayed': historyCount});
        }
      }
    }
  }


  // Update Quiz Metadata
  Future<void> updateQuiz(String quizId, Map<String, dynamic> data) async {
    await _firestore.collection('quizzes').doc(quizId).update(data);
  }

  // Update Question
  Future<void> updateQuestion(String quizId, String questionId, Map<String, dynamic> data) async {
    await _firestore
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .doc(questionId)
            .update(data);
  }

  // Delete Question (Legacy - handled by deleteQuestion above)
  // Field kept for backward compatibility if called elsewhere, but we prefer deleteQuestion
  Future<void> deleteQuestionOld(String quizId, String questionId) async {
    await deleteQuestion(quizId, questionId);
  }
  // Get Real-time Question Count for a Quiz
  Stream<int> getQuestionCountStream(String quizId) {
    return _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
