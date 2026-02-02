import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizContent;
  final String? quizId; // Add quizId

  const QuizScreen({super.key, required this.quizContent, this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selectedOption = -1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Question> _questions = []; // Store fetched questions
  bool _isLoading = true;
  final QuizService _quizService = QuizService();

  // 1. Store User Answers (Key: QuestionIndex, Value: SelectedOptionIndex)
  final Map<int, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // If questions are passed in quizContent, use them (legacy/local support)
    if (widget.quizId != null) {
      debugPrint("Fetching questions for Quiz ID: ${widget.quizId}");
      _quizService.getQuestions(widget.quizId!).listen((questions) {
        debugPrint("Fetched ${questions.length} questions.");
        if (mounted) {
          setState(() {
            _questions = questions;
            _isLoading = false;
          });
        }
      }, onError: (e) {
        debugPrint("Error fetching questions: $e");
        if (mounted) {
          setState(() {
             _isLoading = false; // Fix infinite loading
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading questions: $e")));
        }
      });
    } else {
      // Fallback for null ID (maybe local data?)
       if (widget.quizContent['questions'] != null) {
          // Adapt local json structure to Question model if needed
          // For simplicity, we might skip this or handle it if you strictly want backend.
          // Let's assume for now backend is the way.
          setState(() {
            _isLoading = false;
          });
       } else {
          setState(() {
             _isLoading = false;
          });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int totalQuestions = _questions.length;

    if (totalQuestions == 0) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Black for visibility on white/empty
          onPressed: () => Navigator.pop(context),
        )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "No questions found for this quiz.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please delete this quiz from Admin Panel and create a new one to fix data issues.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text("Quiz ID: ${widget.quizId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final currentQuestionData = _questions[_currentQuestionIndex];
    final String questionText = currentQuestionData.questionText;
    final List<String> options = currentQuestionData.options;
    final int correctAnswerIndex = currentQuestionData.correctOptionIndex;

    final double progress = (_currentQuestionIndex + 1) / totalQuestions;

    void goToNextQuestion() {
      if (_selectedOption == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an option")),
        );
        return;
      }

      // 2. Save the user's answer
      _userAnswers[_currentQuestionIndex] = _selectedOption;

      if (_selectedOption == correctAnswerIndex) {
        _score++;
      }

      if (_currentQuestionIndex < totalQuestions - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = -1;
        });
      } else {
        // 3. Pass data to Score Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreScreen(
              score: _score,
              totalQuestions: totalQuestions,
              quizContent: widget.quizContent, // Pass original quiz data
              userAnswers: _userAnswers,       // Pass user answers
              questions: _questions,           // Pass fetched questions
            ),
          ),
        );
      }
    }

    // ... (Rest of your UI code remains exactly the same) ...
    // Just ensure the 'onPressed' for Next calls 'goToNextQuestion'

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quizContent['title'] ?? "Quiz",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          child: Column(
            children: [
              _buildTimerBar(progress),
              _buildQuestionBanner(_currentQuestionIndex + 1, totalQuestions),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            return _buildOptionWidget(index, options[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Navigation Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _currentQuestionIndex > 0
                                  ? () {
                                setState(() {
                                  _currentQuestionIndex--;
                                  // Restore previous answer if needed
                                  _selectedOption = _userAnswers[_currentQuestionIndex] ?? -1;
                                });
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AFA3),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Previous",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: goToNextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AFA3),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _currentQuestionIndex == totalQuestions - 1
                                    ? "Finish"
                                    : "Next",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets --- (Same as before)
  Widget _buildTimerBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 40,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.3)),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("10 sec", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBanner(int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: ClipPath(
        clipper: AngledBannerClipper(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: Colors.white.withOpacity(0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Question", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18)),
              Text("$current/$total", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionWidget(int index, String text) {
    bool isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: isSelected ? Colors.blue.shade900 : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class AngledBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}