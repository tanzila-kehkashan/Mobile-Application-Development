import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget child; // The screen to go to after the splash

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to the next screen (MyHomePage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.child),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size to help with responsive sizing
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Use the screen's full width and height
        width: double.infinity,
        height: double.infinity,
        // Apply the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Load the background image from assets
            image: AssetImage('assets/images/background.png'),
            // Cover the entire screen
            fit: BoxFit.cover,
          ),
        ),
        // Use a Column to stack the logo and text vertically
        child: Column(
          // Center the content vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // This is the logo
            Image.asset(
              'assets/images/logo.png',
              // Set the logo's width to be 60% of the screen's width
              width: size.width * 0.6,
            ),

            // Add some spacing between the logo and the text
            const SizedBox(height: 24),

            // This is the "Quizzy" title
            const Text(
              'Quizzy',
              style: TextStyle(
                // Use the vibrant cyan color
                color: Color(0xFF00E5BC),
                // Use a large, readable font size
                fontSize: 64,
                // Make the text semi-bold
                fontWeight: FontWeight.w600,
                // Add a little spacing between letters
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}