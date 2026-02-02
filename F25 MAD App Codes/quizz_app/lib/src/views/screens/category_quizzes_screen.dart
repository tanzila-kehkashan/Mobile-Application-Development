import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'quiz_screen.dart';

class CategoryQuizzesScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryQuizzesScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final QuizService quizService = QuizService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Header background
          Container(
            height: 250,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // App Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<List<Quiz>>(
                    stream: quizService.getQuizzes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No quizzes available."));
                      }

                      // Filter quizzes by category
                      final categoryQuizzes = snapshot.data!
                          .where((quiz) => quiz.subtitle == categoryName)
                          .toList();

                      if (categoryQuizzes.isEmpty) {
                        return Center(
                          child: Text(
                            "No quizzes in $categoryName yet.",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: categoryQuizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = categoryQuizzes[index];
                          
                          // Map iconName to IconData
                          IconData iconData = categoryIcon;
                          if (quiz.iconName == 'sports_soccer') iconData = Icons.sports_soccer;
                          if (quiz.iconName == 'music_note') iconData = Icons.music_note;
                          if (quiz.iconName == 'science') iconData = Icons.science;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () {
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
                                      quizId: quiz.id,
                                    ),
                                  ),
                                );
                              },
                              child: StreamBuilder<int>(
                                stream: quizService.getQuestionCountStream(quiz.id),
                                builder: (context, countSnapshot) {
                                  final count = countSnapshot.data ?? 0;
                                  return _buildQuizCard(
                                    title: quiz.title,
                                    questionCount: count,
                                    icon: iconData,
                                    color: Color(quiz.colorHex),
                                  );
                                }
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard({
    required String title,
    required int questionCount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$questionCount Questions",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 18,
          ),
        ],
      ),
    );
  }
}
