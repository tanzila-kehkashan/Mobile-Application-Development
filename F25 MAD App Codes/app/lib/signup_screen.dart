import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/services/auth_service.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/email_verification_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.length < 3) {
      setState(() => _isUsernameAvailable = false);
      return;
    }
    setState(() => _isCheckingUsername = true);
    try {
      final available = await _firestoreService.isUsernameAvailable(username);
      if (mounted) {
        setState(() {
          _isUsernameAvailable = available;
          _isCheckingUsername = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingUsername = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose an available username'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Auth (sends verification email automatically)
      await _authService.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      // Update display name
      await _authService.updateDisplayName(nameController.text);

      // Navigate to email verification screen
      // Firestore profile will be created after email is verified
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            page: EmailVerificationScreen(
              displayName: nameController.text.trim(),
              username: usernameController.text.trim().toLowerCase(),
            ),
          ),
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
                    const Text(
                      'Nexus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Create Account title
                    const Center(
                      child: Text(
                        'Create Account Now!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name field
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE3D8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
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
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: Colors.black38),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            height: 0.8,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Username field
                    const Text(
                      'Username',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE3D8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextFormField(
                        controller: usernameController,
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
                          hintText: 'Choose a unique username',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixText: '@',
                          prefixStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          suffixIcon: _isCheckingUsername
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : usernameController.text.length >= 3
                                  ? Icon(
                                      _isUsernameAvailable
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: _isUsernameAvailable
                                          ? Colors.green
                                          : Colors.red,
                                    )
                                  : null,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            height: 0.8,
                          ),
                        ),
                        onChanged: (value) {
                          _checkUsernameAvailability(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'Only letters, numbers, and underscores';
                          }
                          if (!_isUsernameAvailable) {
                            return 'Username is already taken';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email field
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
                    Container(
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
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
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
                          hintText: 'Create a password',
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
                            return 'Please enter password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password field
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
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE3D8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextFormField(
                        controller: confirmPassController,
                        obscureText: _obscureConfirmPassword,
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
                          hintText: 'Confirm your password',
                          hintStyle: const TextStyle(color: Colors.black38),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
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
                            return 'Please confirm your password';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Terms checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
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
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'I agree to the Terms of Service & Privacy Policy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Signup button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
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
                                'SIGNUP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login text
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have Account? ',
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
                                        page: const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  'LOGIN',
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
                    ),

                    const SizedBox(height: 40),

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
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }
}
