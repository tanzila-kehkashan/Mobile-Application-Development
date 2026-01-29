import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Using Inter as a clean, modern font
      ),
      debugShowCheckedModeBanner: false,
      home: const QuizScreen(),
    );
  }
}

// ----------------------------------------------
// Quiz Screen Code (from quiz_screen.dart)
// ----------------------------------------------

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // State variable to track the selected option
  int _selectedOption = -1; // -1 means no option is selected

  // Dummy data for the quiz - UPDATED to match Quiz2.png
  final String _question = "What is Flutter Widget";
  final List<String> _options = [
    "1. Physical Device",
    "2. Building UI",
    "3. Navigation Feature",
    "4. DBMS",
  ];
  final int _currentQuestion = 3;
  final int _totalQuestions = 4;
  final double _progress = 0.75; // Represents 3 out of 4
  final String _timeLeft = "0 sec"; // Dummy time updated

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          "Flutter Quiz",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Use BoxDecoration to set the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            // IMPORTANT: Replace this with your local asset path
            // e.g., 'assets/background.png'
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Timer and Progress Bar
              _buildTimerBar(),

              // Question Counter Banner
              _buildQuestionBanner(),

              // Main Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  // Padding for the content inside the white card
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
                      // Question Text
                      Text(
                        _question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Options List
                      ListView.builder(
                        shrinkWrap: true, // To make it work inside a Column
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          return _buildOptionWidget(index);
                        },
                      ),
                      const SizedBox(height: 16),

                      // See Result Link
                      Text(
                        "See Result",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(), // Pushes buttons to the bottom

                      // Navigation Buttons
                      _buildNavigationButtons(),
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

  /// Builds the timer bar widget
  Widget _buildTimerBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          // The background of the bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // The progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 40,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.3)),
            ),
          ),
          // The text and icon on top
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _timeLeft,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const Icon(
                  Icons.timer_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the angled question counter banner
  Widget _buildQuestionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      // ClipPath to create the angled effect
      child: ClipPath(
        clipper: AngledBannerClipper(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: Colors.white.withOpacity(0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Question",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                ),
              ),
              Text(
                "$_currentQuestion/$_totalQuestions",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single answer option widget
  Widget _buildOptionWidget(int index) {
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
            Text(
              _options[index],
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.blue.shade900 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade700,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the bottom navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Previous button tap
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Previous",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Next Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Next button tap
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Next",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomClipper to create the angled banner effect
class AngledBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This creates the trapezoid shape for the banner
    Path path = Path();
    path.moveTo(size.width * 0.1, 0); // Start 10% from left on the top edge
    path.lineTo(size.width, 0); // Go to top-right
    path.lineTo(size.width, size.height); // Go to bottom-right
    path.lineTo(0, size.height); // Go to bottom-left
    path.close(); // Connect back to the start
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}