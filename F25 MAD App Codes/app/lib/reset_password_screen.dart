import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'login_screen.dart'; // Import the login screen

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4A5A5),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // App title
                  const Text(
                    'NEXUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Forgot Password title
                  const Center(
                    child: Text(
                      'Forgot Password!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),

                  // Email label
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email input field
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE3D8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        hintText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // New Password label
                  const Text(
                    'New Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // New Password input field
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE3D8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        hintText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Confirm Password label
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Confirm Password input field
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE3D8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        hintText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate passwords match
                        if (newPasswordController.text.isNotEmpty &&
                            newPasswordController.text ==
                                confirmPasswordController.text) {

                          // Show Success Message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password Reset Successful'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate to Login Screen
                          Navigator.push(
                            context,
                            FadePageRoute(page: const LoginScreen()),
                          );

                        } else {
                          // Show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match or are empty'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4C4A8),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'CONFIRM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Bottom indicator
                  Center(
                    child: Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
