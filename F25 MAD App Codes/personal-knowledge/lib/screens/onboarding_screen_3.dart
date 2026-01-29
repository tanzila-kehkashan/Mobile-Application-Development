import 'package:flutter/material.dart';
import 'auth/signup_choice_screen.dart';

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to onboarding 2
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Image
              SizedBox(
                height: 260,
                child: Image.asset(
                  'assets/images/onboarding_3.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Progress Bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Create notes and\neasy styling',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Making your content legible has never been easier.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignupChoiceScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
