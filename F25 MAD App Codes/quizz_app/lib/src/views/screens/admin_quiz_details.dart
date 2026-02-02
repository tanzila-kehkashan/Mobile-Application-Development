import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'addQuestionn_screen.dart';

class AdminQuizDetailsScreen extends StatefulWidget {
  final Quiz quiz;
  const AdminQuizDetailsScreen({super.key, required this.quiz});

  @override
  State<AdminQuizDetailsScreen> createState() => _AdminQuizDetailsScreenState();
}

class _AdminQuizDetailsScreenState extends State<AdminQuizDetailsScreen> {
  final QuizService _quizService = QuizService();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.title);
    _subtitleController = TextEditingController(text: widget.quiz.subtitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      await _quizService.updateQuiz(widget.quiz.id, {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quiz updated!"), backgroundColor: Colors.green),
        );
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3a3a3a), elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? "Edit Quiz Info" : "Quiz Manager"),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
              tooltip: _isEditing ? "Save Changes" : "Edit Info",
            )
          ],
        ),
        body: Column(
          children: [
            // Quiz Info Header
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF3e3e3e),
              child: Column(
                children: [
                  _buildTextField("Title", _titleController, _isEditing),
                  const SizedBox(height: 10),
                  _buildTextField("Subtitle", _subtitleController, _isEditing),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: StreamBuilder<List<Question>>(
                stream: _quizService.getQuestions(widget.quiz.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No questions added yet."));
                  }

                  final questions = snapshot.data!;
                  return ListView.builder(
                    itemCount: questions.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _buildQuestionCard(question, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToAddQuestion(context),
          label: const Text("Add Question", style: TextStyle(color: Colors.black)),
          icon: const Icon(Icons.add, color: Colors.black),
          backgroundColor: const Color(0xFF26E3BA),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool enabled) {
    if (!enabled) {
      return Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(controller.text, style: const TextStyle(fontSize: 16, color: Colors.white))),
        ],
      );
    }
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        isDense: true,
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      color: Colors.grey.shade800,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF26E3BA),
          child: Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        title: Text(question.questionText, style: const TextStyle(color: Colors.white)),
        subtitle: Text("Correct Answer: ${question.options[question.correctOptionIndex]}", style: TextStyle(color: Colors.white.withOpacity(0.7))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => _navigateToEditQuestion(context, question),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteQuestion(question.id),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteQuestion(String questionId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Question", style: TextStyle(color: Colors.black)), // Added style for visibility in white dialog
        content: const Text("Are you sure? This cannot be undone.", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _quizService.deleteQuestion(widget.quiz.id, questionId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  void _navigateToAddQuestion(BuildContext context) async {
     final newQuestionData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(categoryTitle: widget.quiz.title),
      ),
    );

    if (newQuestionData != null) {
      await _quizService.addQuestion(widget.quiz.id, newQuestionData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Question added!"), backgroundColor: Colors.green));
      }
    }
  }

  void _navigateToEditQuestion(BuildContext context, Question question) async {
    // We need to update AddQuestionScreen to accept existing data
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          categoryTitle: widget.quiz.title,
          existingQuestion: question, // Pass existing question
        ),
      ),
    );

    if (updatedData != null) {
      await _quizService.updateQuestion(widget.quiz.id, question.id, updatedData);
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Question updated!"), backgroundColor: Colors.green));
      }
    }
  }
}
