import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_hub/providers/auth_provider.dart';
import 'verification_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _emailValidator(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Helper to validate all inputs before calling Firebase
  bool _validateInputs() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return false;
    }
    if (!_emailValidator(email)) {
      _showSnackBar('Invalid Email', isError: true);
      return false;
    }
    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters', isError: true);
      return false;
    }
    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _signup() async {
    if (!_validateInputs()) return;

    final authService = ref.read(authServiceProvider);
    final firestore = FirebaseFirestore.instance; // Or use your provider

    setState(() => _isLoading = true);

    try {
      // 1. Create the user in Firebase Auth
      final userCredential = await authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Update the Profile Display Name
        await user.updateDisplayName(_nameController.text.trim());

        // 3. Save additional info to Firestore
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false, // Initial state
          'followingCount': 0,
          'followerCount': 0,
          'bio': 'Welcome to Event Hub!',
          'interests': ['Gaming', 'Music', 'Art'],
        });
        authService.signOut();

        // 4. Send the Verification Email
        await user.sendEmailVerification();

        bool isVerified = await authService.isEmailVerified();

        if(!isVerified){
          authService.signOut();
        }

        if (mounted) {
          setState(() => _isLoading = false);

          _showSnackBar('Verification email sent! Please check your inbox.', isError: false);

          // 5. Move to Verification Screen
          // We use pushAndRemoveUntil so they can't simply click "back" to the form
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
                (route) => false,
          );
        }
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
        // Facebook users are usually verified by Facebook,
        // but you can still check userCredential.user.emailVerified
        _showSnackBar('Success!', isError: false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Facebook Sign-Up failed', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isError ? '❌ $message' : '✅ $message'),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/images/eventhublogo.png', height: 60),
              ),
              const SizedBox(height: 40),
              const Text(
                'Sign up',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Full name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'abc@email.com', Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Your password', Icons.lock_outline, isPassword: true,
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
              const SizedBox(height: 16),
              _buildTextField(_confirmPasswordController, 'Confirm password', Icons.lock_outline, isPassword: true,
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B4EFF)))
                  : ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4EFF),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SIGN UP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithFacebook,
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text('Sign up with Facebook', style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign in', style: TextStyle(color: Color(0xFF5B4EFF), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      {bool isPassword = false, bool obscure = false, VoidCallback? onToggle, TextInputType type = TextInputType.text}
      ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: onToggle)
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