import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/analytics_service.dart';
import '../notes/home_notes_screen.dart';
import 'signup_form_screen.dart';
import 'forgot_password_screen.dart';

import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
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

    try {
      // Sign in with Firebase
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user to get latest email verification status
      await _authService.reloadUser();

      // Check if email is verified
      if (!_authService.isEmailVerified) {
        // Sign out the user if email is not verified
        await _authService.signOut();
        
        if (mounted) {
          setState(() {
            _errorMessage = 'Please verify your email address before logging in. Check your inbox for the verification link.';
            _isLoading = false;
          });
          
          // Show option to resend verification email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email not verified. Would you like to resend the verification email?'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Resend',
                textColor: Colors.white,
                onPressed: () async {
                  // Re-sign in temporarily to resend email
                  try {
                    await _authService.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    await _authService.resendVerificationEmail();
                    await _authService.signOut();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent! Please check your inbox.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to resend email: ${e.toString().replaceAll('Exception: ', '')}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
        return;
      }

      // Log analytics event
      await _analyticsService.logLogin(loginMethod: 'email');

      // Navigate to home screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadeSlidePageRoute(page: const HomeNotesScreen()),
          (route) => false,  // Remove all previous routes
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM(context), vertical: AppSizes.paddingS(context)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, Welcome! 👋",
                  style: TextStyle(fontSize: AppSizes.fontM(context), fontWeight: FontWeight.bold),
                ),
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

                Text(
                  "Email",
                  style: TextStyle(fontSize: AppSizes.fontM(context), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM(context), vertical: AppSizes.paddingS(context)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "Password",
                  style: TextStyle(fontSize: AppSizes.fontM(context), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM(context), vertical: AppSizes.paddingS(context)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        FadeSlidePageRoute(page: const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Color(0xFF007AFF)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : handleLogin,
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
                            'Log In',
                            style: TextStyle(fontSize: AppSizes.fontM(context), color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          FadeSlidePageRoute(page: SignUpFormScreen()),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(color: Color(0xFF007AFF)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
