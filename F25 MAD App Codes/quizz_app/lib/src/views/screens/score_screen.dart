import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'review_screen.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/services/auth_service.dart';
import 'package:quizz_app/src/models/user_score_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:quizz_app/src/models/quiz_history_model.dart';
import 'package:quizz_app/src/models/quiz_model.dart'; // Add import

class ScoreScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final Map<String, dynamic> quizContent;
  final Map<int, int> userAnswers;
  final List<Question> questions; // Add this field

  const ScoreScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.quizContent,
    required this.userAnswers,
    required this.questions, // Add required
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();
  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userScore = UserScore(
        id: '', // ID will be handled by logic or ignored if custom ID used
        userId: user.uid,
        userName: user.displayName ?? (user.email?.split('@')[0] ?? 'User'), // Use displayName if available
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        timestamp: DateTime.now(),
      );
      
      try {
        await _quizService.saveUserScore(userScore);
        
        // Save History
        final history = QuizHistory(
            id: '', 
            quizTitle: widget.quizContent['title'] ?? 'Quiz', 
            score: widget.score, 
            totalQuestions: widget.totalQuestions, 
            timestamp: DateTime.now()
        );
        await _quizService.saveQuizHistory(user.uid, history);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Score and History saved!")));
        }
      } catch (e) {
        debugPrint("Error saving score: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save score: $e")));
        }
      }
    }
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Result",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.shade300.withOpacity(0.5),
                                    width: 4,
                                  ),
                                ),
                              ),
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.shade700,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Your Score",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${widget.score}/${widget.totalQuestions}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_isSaving)
                            const Text(
                              "Saving Score...",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            "Congratulations",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Great job, You Did It",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(), // This now works inside IntrinsicHeight

                          // --- REVIEW BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewScreen(
                                      quizContent: widget.quizContent,
                                      userAnswers: widget.userAnswers,
                                      questions: widget.questions, // Pass the questions list
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C6AE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Review",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Next Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                        (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C6AE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Home",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}