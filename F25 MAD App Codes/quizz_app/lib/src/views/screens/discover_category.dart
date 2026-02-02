import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'category_quizzes_screen.dart';

class DiscoverCategoryView extends StatelessWidget {
  final String searchQuery;
  
  const DiscoverCategoryView({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final QuizService quizService = QuizService();

    return StreamBuilder<List<Quiz>>(
      stream: quizService.getQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No categories available yet."));
        }

        final quizzes = snapshot.data!;
        // Extract unique categories (subtitles) and finding a representative quiz for styling
        final Map<String, Quiz> categoryMap = {};
        for (var quiz in quizzes) {
          if (quiz.subtitle.isNotEmpty && !categoryMap.containsKey(quiz.subtitle)) {
            categoryMap[quiz.subtitle] = quiz;
          }
        }

        var categories = categoryMap.values.toList();
        
        // Filter categories based on search query
        if (searchQuery.isNotEmpty) {
          categories = categories.where((quiz) {
            return quiz.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
        }
        
        if (categories.isEmpty) {
           return Center(
             child: Text(
               searchQuery.isNotEmpty 
                 ? "No categories found for '$searchQuery'"
                 : "No categories found.",
               style: const TextStyle(color: Colors.grey),
             ),
           );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final quiz = categories[index];
            final categoryName = quiz.subtitle;

             // Map iconName String to IconData
            IconData iconData = Icons.category;
             if (quiz.iconName == 'sports_soccer') iconData = Icons.sports_soccer;
             if (quiz.iconName == 'music_note') iconData = Icons.music_note;
             if (quiz.iconName == 'science') iconData = Icons.science;


            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryQuizzesScreen(
                        categoryName: categoryName,
                        categoryColor: Color(quiz.colorHex),
                        categoryIcon: iconData,
                      ),
                    ),
                  );
                },
                child: _buildCategoryItem(
                  icon: iconData,
                  title: categoryName,
                  iconColor: Color(quiz.colorHex),
                  iconBackgroundColor: Color(quiz.colorHex).withOpacity(0.1),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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