import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'admin_quiz_details.dart';

class AllQuizzesScreen extends StatelessWidget {
  const AllQuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizService quizService = QuizService();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3a3a3a),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ALL QUIZZES', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Quiz>>(
          stream: quizService.getQuizzes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final quizzes = snapshot.data ?? [];

            if (quizzes.isEmpty) {
              return const Center(
                child: Text(
                  "No quizzes found. Create one!",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                return _buildQuizCard(context, quizzes[index], quizService);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz, QuizService quizService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3e3e3e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getIconData(quiz.iconName), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                StreamBuilder<int>(
                  stream: quizService.getQuestionCountStream(quiz.id),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text(
                      '${quiz.subtitle} • $count Qs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminQuizDetailsScreen(quiz: quiz),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26E3BA),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text("Manage"),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(context, quiz.id, quizService),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String quizId, QuizService quizService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Quiz", style: TextStyle(color: Colors.black)),
        content: const Text("Are you sure? All questions in this quiz will also be deleted.", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              quizService.deleteQuiz(quizId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'music_note':
        return Icons.music_note;
      case 'science':
        return Icons.science;
      default:
        return Icons.quiz;
    }
  }
}
