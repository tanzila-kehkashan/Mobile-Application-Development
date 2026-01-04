import 'package:event_hub/auth_screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_hub/providers/auth_provider.dart';
import 'sign_up_screen.dart';
import 'verification_screen.dart'; // Import this to redirect if unverified

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _emailValidator(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // --- Core Authentication Logic ---
  Future<void> _authenticate() async {
    final authService = ref.read(authServiceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_emailValidator(email)) {
      _showSnackBar('Invalid Email', isError: true);
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 1. Attempt Sign In
      final userCredential = await authService.signInWithEmailPassword(email, password);
      final user = userCredential.user;

      // 2. IMPORTANT: Reload user to get latest verification status from Firebase
      await user?.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      // 3. Verify Check
      if (updatedUser != null && !updatedUser.emailVerified) {
        // Log them out immediately so the app listener doesn't move them to Home
        await authService.signOut();

        setState(() => _isLoading = false);
        _showSnackBar('Email not verified. Please check your inbox.', isError: true);

        // Optional: Redirect to verification help screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
        return;
      }

      // 4. Handle Remember Me
      if (_rememberMe) {
        await authService.saveCredentials(email, password);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Login Successful', isError: false);
        // Navigation happens automatically via authStateProvider in main.dart
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(_getErrorMessage(e.code), isError: true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  Future<void> _signInWithFacebook() async {
    final authService = ref.read(authServiceProvider);
    try {
      setState(() => _isLoading = true);
      final userCredential = await authService.signInWithFacebook();
      if (userCredential != null && mounted) {
        _showSnackBar('Facebook Sign-In Successful', isError: false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Facebook Sign-In failed', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isError ? '❌ $message' : '✅ $message'),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/eventhublogo.png', height: 60),
              const SizedBox(height: 40),
              const Text(
                'Sign in',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              // Email Field
              _buildTextField(
                controller: _emailController,
                hint: 'abc@email.com',
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password Field
              _buildTextField(
                controller: _passwordController,
                hint: 'Your password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 12),
              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _rememberMe,
                        onChanged: (val) => setState(() => _rememberMe = val),
                        activeColor: const Color(0xFF5B4EFF),
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordScreen())),
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.black87)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sign In Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B4EFF)))
                  : ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4EFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SIGN IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // OR Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),
              // Facebook
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithFacebook,
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text('Login with Facebook', style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: const Text('Sign up', style: TextStyle(color: Color(0xFF5B4EFF), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
          onPressed: onToggle,
        )
            : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B4EFF))),
      ),
    );
  }
}