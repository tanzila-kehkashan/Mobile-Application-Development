import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help Centre',
      theme: ThemeData(
        // Use a dark theme to match the screenshot
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        // Set scaffold background to transparent by default
        // so our background image container shows through.
        scaffoldBackgroundColor: Colors.transparent,
        // Set the default text field cursor color to be visible on white
        textSelectionTheme:
        const TextSelectionThemeData(cursorColor: Colors.blue),
      ),
      home: const HelpCentreScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  // Helper method to build styled TextFields
  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextFormField(
      // For the typed text
      style: const TextStyle(color: Colors.black87),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        // For the hint text
        hintStyle: TextStyle(color: Colors.grey[600]),
        // White background
        filled: true,
        fillColor: Colors.white,
        // Rounded corners, no border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  // Helper method to show the success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // White background
          backgroundColor: Colors.white,
          // Rounded corners to match the screenshot
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          // The content of the dialog
          content: const Column(
            mainAxisSize: MainAxisSize.min, // Keep it compact
            children: [
              SizedBox(height: 20), // Padding at the top
              Text(
                'Successfully submitted!!',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Padding at the bottom
            ],
          ),
          // No title, no actions, just the content
          // The dialog will be dismissed when tapping outside
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the body's background image to extend behind the app bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Make the app bar transparent
        backgroundColor: Colors.transparent,
        // Remove the shadow
        elevation: 0,
        // Add the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle the back button press
            print("Back button pressed");
          },
        ),
        // Add the title
        title: const Text(
          'Help Centre',
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
            // Make sure you add 'assets/background.png' to your pubspec.yaml
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Use SafeArea to avoid UI overlapping with status bar/notch
        child: SafeArea(
          // Use SingleChildScrollView to prevent overflow when keyboard appears
          child: SingleChildScrollView(
            child: Padding(
              // Add horizontal padding for the form
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                // Align "Contact Us" to the left
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add some space from the top (after SafeArea)
                  const SizedBox(height: 24.0),
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  _buildTextField(hint: 'Enter your name'),
                  const SizedBox(height: 16.0),
                  _buildTextField(hint: 'Enter your email'),
                  const SizedBox(height: 16.0),
                  _buildTextField(hint: 'Subject'),
                  const SizedBox(height: 16.0),
                  _buildTextField(hint: 'Your Message', maxLines: 5),
                  const SizedBox(height: 24.0),
                  // Center the submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                        print("Submit button pressed");
                        // Show the success dialog
                        _showSuccessDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        // This color is sampled from your screenshot
                        backgroundColor: const Color(0xFF00E6C3),
                        // Text color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0), // Extra space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}