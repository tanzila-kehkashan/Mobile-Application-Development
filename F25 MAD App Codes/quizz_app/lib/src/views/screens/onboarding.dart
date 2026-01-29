import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Using a common font, you can change this
      ),
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Set the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top navigation (Back button and Skip)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Handle back button press
                        debugPrint("Back button pressed");
                      },
                    ),
                    TextButton(
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        // Handle skip button press
                        debugPrint("Skip button pressed");
                      },
                    ),
                  ],
                ),
              ),

              // Main content (Image and Text)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stack for the illustration with background shapes
                    SizedBox(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // White-ish blob shape (rotated)
                          Transform.rotate(
                            angle: -0.15, // Rotate slightly
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                          ),
                          // Light blue card
                          Container(
                            margin: const EdgeInsets.all(12), // Inner padding
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF0F6), // Light blue color
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              // --- IMPORTANT ---
                              // Replace this Icon with your illustration
                              // Example:
                              // Image.asset(
                              //   'assets/images/your_illustration.png',
                              //   fit: BoxFit.contain,
                              // ),
                              child: Icon(
                                Icons.person_search,
                                size: size.width * 0.4,
                                color: Colors.blueGrey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Title Text
                    const Text(
                      "Test Your Knowledge",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle Text
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Challenge Yourself with a variety of Quizzes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5, // Line height
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageIndicator(isActive: false),
                    const SizedBox(width: 8),
                    _buildPageIndicator(isActive: true),
                    const SizedBox(width: 8),
                    _buildPageIndicator(isActive: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the page indicator dots
  Widget _buildPageIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: isActive ? 30 : 10, // Active dot is wider
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}