import 'package:quizz_app/src/models/quiz_model.dart';
import 'package:flutter/material.dart';

class AddQuestionScreen extends StatefulWidget {
  final String categoryTitle;
  final Question? existingQuestion; // Optional: for editing

  const AddQuestionScreen({
    super.key,
    required this.categoryTitle,
    this.existingQuestion,
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();
  final TextEditingController _option3Controller = TextEditingController();
  final TextEditingController _option4Controller = TextEditingController();
  final TextEditingController _correctAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      final q = widget.existingQuestion!;
      _questionController.text = q.questionText;
      if (q.options.length >= 4) {
        _option1Controller.text = q.options[0];
        _option2Controller.text = q.options[1];
        _option3Controller.text = q.options[2];
        _option4Controller.text = q.options[3];
      }
      _correctAnswerController.text = (q.correctOptionIndex + 1).toString();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  void _createQuestion() {
    if (_questionController.text.isEmpty ||
        _option1Controller.text.isEmpty ||
        _option2Controller.text.isEmpty ||
        _option3Controller.text.isEmpty ||
        _option4Controller.text.isEmpty ||
        _correctAnswerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final int? correctOption = int.tryParse(_correctAnswerController.text);
    if (correctOption == null || correctOption < 1 || correctOption > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Correct option must be between 1 and 4"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _showSuccessDialog();
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            widget.existingQuestion != null ? 'Question Updated!' : 'Quiz created successfully!!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                child: const Text('Ok'),
                onPressed: () {
                  // 1. CREATE THE QUESTION OBJECT
                  Map<String, dynamic> newQuestion = {
                    'questionText': _questionController.text,
                    'options': [
                      _option1Controller.text,
                      _option2Controller.text,
                      _option3Controller.text,
                      _option4Controller.text,
                    ],
                    // Convert "1" -> 0 index, "2" -> 1 index, etc.
                    'correctOptionIndex': (int.tryParse(_correctAnswerController.text) ?? 1) - 1,
                  };

                  Navigator.of(context).pop(); // Close Dialog

                  // 2. PASS THE DATA BACK TO DASHBOARD
                  Navigator.of(context).pop(newQuestion);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF303030),
        appBar: AppBar(
          backgroundColor: const Color(0xFF303030),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.existingQuestion != null ? 'Edit Question' : 'Add Question to ${widget.categoryTitle}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(controller: _questionController, label: 'Question'),
                const SizedBox(height: 16),
                _buildTextField(controller: _option1Controller, label: 'Option 1'),
                const SizedBox(height: 16),
                _buildTextField(controller: _option2Controller, label: 'Option 2'),
                const SizedBox(height: 16),
                _buildTextField(controller: _option3Controller, label: 'Option 3'),
                const SizedBox(height: 16),
                _buildTextField(controller: _option4Controller, label: 'Option 4'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _correctAnswerController,
                  label: 'Correct Answer (1-4)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AFA3),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _createQuestion,
                  child: Text(
                    widget.existingQuestion != null ? 'Update' : 'Create',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}