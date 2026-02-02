import 'package:flutter/material.dart';
import 'main_dashboard.dart';

void main() {
  runApp(const SignUpSuccessApp());
}

class SignUpSuccessApp extends StatelessWidget {
  const SignUpSuccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up Success',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial', useMaterial3: true),
      home: const SignUpSuccessScreen(),
    );
  }
}

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  // App Colors
  static const Color orangeColor = Color(0xFFF6921E);
  static const Color iconBlueColor = Color(0xFF5C9DFF);
  static const Color backgroundColor = Color(0xFFEFF6FF);
  static const Color darkTextColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.black54,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(height: 20),

              // Top Header Text
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: darkTextColor,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: 'Smart '),
                        TextSpan(
                          text: 'Inventory\n',
                          style: TextStyle(color: orangeColor),
                        ),
                        TextSpan(text: 'Management'),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Central Illustration (Gears & Boxes)
              SizedBox(
                height: 240,
                width: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    // Gear Top Left
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Icon(
                        Icons.settings,
                        size: 90,
                        color: iconBlueColor.withOpacity(0.9),
                      ),
                    ),
                    // Gear Middle Right
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Icon(
                        Icons.settings_outlined,
                        size: 70,
                        color: iconBlueColor.withOpacity(0.8),
                      ),
                    ),
                    // Box Bottom Left
                    Positioned(
                      bottom: 20,
                      left: 10,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 100,
                        color: iconBlueColor,
                      ),
                    ),
                    // Box Bottom Right
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: Icon(
                        Icons.check_box_outline_blank,
                        size: 90,
                        color: iconBlueColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // "all in one place" text
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: 'all in one '),
                    TextSpan(
                      text: 'place',
                      style: TextStyle(color: orangeColor),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // "Sign up Successfully" text
              const Text(
                'Sign up Successfully',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 30),

              // "Continue" Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
