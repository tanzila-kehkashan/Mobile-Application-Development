import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/services/auth_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadePageRoute(page: const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // App title
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 100),
                      beginOffset: const Offset(-0.3, 0),
                      child: const Text(
                        'NEXUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Welcome Back title
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: const Center(
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login to continue text
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: const Center(
                        child: Text(
                          'Login to continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Email label
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      beginOffset: const Offset(0.3, 0),
                      child: const Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Email input field
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 450),
                      beginOffset: const Offset(0.3, 0),
                      child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE3D8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextFormField(
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
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.black38),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            height: 0.8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    )),

                    const SizedBox(height: 32),

                    // Password label
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 500),
                      beginOffset: const Offset(0.3, 0),
                      child: const Text(
                        'Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    )),

                    const SizedBox(height: 12),

                    // Password input field
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 550),
                      beginOffset: const Offset(0.3, 0),
                      child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE3D8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: Colors.black38),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            height: 0.8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    )),

                    const SizedBox(height: 16),

                    // Remember me and Forget password row
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 600),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                                fillColor: WidgetStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.white;
                                    }
                                    return const Color(0xFFEAE3D8);
                                  },
                                ),
                                checkColor: const Color(0xFFB4A5A5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                  page: const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forget password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 48),

                    // Login button
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 700),
                      beginOffset: const Offset(0, 0.3),
                      child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4C4A8),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          disabledBackgroundColor:
                              const Color(0xFFD4C4A8).withValues(alpha: 0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black54),
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    )),

                    const SizedBox(height: 24),

                    // Sign up text
                    FadeAnimation(
                      delay: const Duration(milliseconds: 800),
                      child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlidePageRoute(
                                        page: const SignupScreen()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFFD4C4A8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 40),
                  ],
                ),
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
    passwordController.dispose();
    super.dispose();
  }
}
