import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/analytics_service.dart';
import 'email_verification_screen.dart';

import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';
class SignUpFormScreen extends StatefulWidget {
  const SignUpFormScreen({super.key});

  @override
  State<SignUpFormScreen> createState() => _SignUpFormScreenState();
}

class _SignUpFormScreenState extends State<SignUpFormScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> handleSignUp() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
        _isLoading = false;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    try {
      // Create account with Firebase
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      await _authService.sendEmailVerification();

      // Log analytics event
      await _analyticsService.logSignUp(signUpMethod: 'email');

      // Sign out the user to prevent auto-login without verification
      await _authService.signOut();

      // Navigate to email verification screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadeSlidePageRoute(page: EmailVerificationScreen(email: email)),
          (route) => false,  // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create account"),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM(context), vertical: AppSizes.paddingS(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Show error message if any
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(AppSizes.paddingM(context)),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 6 characters',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Create account',
                      style: TextStyle(fontSize: AppSizes.fontM(context), color: Colors.white),
                    ),
            ),

            const SizedBox(height: 16),
            Text(
              "By creating an account you agree to our Terms & Conditions",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontM(context), color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
