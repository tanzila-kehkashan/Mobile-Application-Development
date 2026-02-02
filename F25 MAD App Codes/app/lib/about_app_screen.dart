import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Matching the theme color
    const Color backgroundColor = Color(0xFFEBE3E3);
    const Color foregroundColor = Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'About App',
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: foregroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school, // Using the app's theme icon
                size: 50,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NEXUS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Connecting students, facilitating learning, and building the future together.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: foregroundColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
