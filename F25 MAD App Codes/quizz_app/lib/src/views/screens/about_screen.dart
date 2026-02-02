import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the body's background image to extend behind the app bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Make the app bar transparent
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to Settings
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'About App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        // Set the background image
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Use a Center widget to center the content card
        child: Center(
          child: Container(
            // Add horizontal margin to match the screenshot
            margin: const EdgeInsets.symmetric(horizontal: 32.0),
            // Add internal padding for the text
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              // Semi-transparent card color
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Text(
              'As the developer of the Quiz App, '
                  'I designed and built this platform '
                  'to make learning and knowledge '
                  'assessment more engaging and interactive. '
                  'My goal was to create a simple yet '
                  'powerful web application that allows '
                  'users to participate in quizzes, '
                  'test their knowledge, and '
                  'compete with others in real-time.',
              style: TextStyle(
                color: Colors. white,
                fontSize: 16.0,
                // Adjust line spacing for better readability
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}