import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'quiz_screen.dart'; // Import Quiz Screen

class DiscoverQuizView extends StatelessWidget {
  final String searchQuery;
  
  const DiscoverQuizView({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final QuizService quizService = QuizService(); // Instance

    return StreamBuilder<List<Quiz>>(
      stream: quizService.getQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No quizzes available yet."),
          );
        }

        var quizzes = snapshot.data!;
        
        // Filter based on search query
        if (searchQuery.isNotEmpty) {
          quizzes = quizzes.where((quiz) {
            return quiz.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                   quiz.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
        }
        
        if (quizzes.isEmpty) {
          return Center(
            child: Text(
              "No quizzes found for '$searchQuery'",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            
            // Map iconName String to IconData (Helper logic duplicated for display)
            IconData iconData = Icons.article;
            if (quiz.iconName == 'sports_soccer') iconData = Icons.sports_soccer;
            if (quiz.iconName == 'music_note') iconData = Icons.music_note;
            if (quiz.iconName == 'science') iconData = Icons.science;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                 onTap: () {
                     // Create compatibility map for QuizScreen
                     final quizMap = {
                       'title': quiz.title,
                       'subtitle': quiz.subtitle,
                       'icon': iconData,
                       'iconColor': Color(quiz.colorHex),
                       'bgColor': Color(quiz.colorHex).withOpacity(0.2),
                     };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          quizContent: quizMap,
                          quizId: quiz.id, // Pass quiz.id
                        ),
                      ),
                    );
                 },
                child: StreamBuilder<int>(
                  stream: quizService.getQuestionCountStream(quiz.id),
                  builder: (context, countSnapshot) {
                    final count = countSnapshot.data ?? 0;
                    return _buildQuizItem(
                      icon: iconData,
                      title: quiz.title,
                      subtitle: "${quiz.subtitle} • $count Qs",
                      iconColor: Color(quiz.colorHex),
                      iconBackgroundColor: Color(quiz.colorHex).withOpacity(0.1),
                    );
                  }
                ),
              ),
            );
          },
        );
      }
    );
  }

  // Helper widget to build the quiz card
  Widget _buildQuizItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBackgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: iconColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}