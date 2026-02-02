import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/home_screen.dart';
import 'package:nexus/welcome_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? displayName;
  final String? username;

  const EmailVerificationScreen({
    super.key,
    this.displayName,
    this.username,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Timer? _verificationTimer;
  bool _isLoading = false;
  bool _isResending = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Reload user to get latest email verification status
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      _verificationTimer?.cancel();
      await _completeRegistration(refreshedUser);
    }
  }

  Future<void> _manualCheckVerification() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Session expired. Please sign up again.');
        _navigateToWelcome();
        return;
      }

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        _verificationTimer?.cancel();
        await _completeRegistration(refreshedUser);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your inbox and click the verification link.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error checking verification: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeRegistration(User user) async {
    setState(() => _isLoading = true);

    try {
      // Check if user profile already exists in Firestore
      final existingUser = await _firestoreService.getUser(user.uid);
      
      if (existingUser == null) {
        // Create user profile in Firestore
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: widget.username,
          displayName: widget.displayName ?? user.displayName,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(userModel);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified! Welcome to Nexus!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          FadePageRoute(page: const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Error completing registration: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Session expired. Please sign up again.');
        _navigateToWelcome();
        return;
      }

      await user.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Start cooldown
        setState(() {
          _canResend = false;
          _resendCooldown = 60;
        });

        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCooldown > 0) {
            setState(() => _resendCooldown--);
          } else {
            timer.cancel();
            setState(() => _canResend = true);
          }
        });
      }
    } catch (e) {
      _showError('Error sending email: $e');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToWelcome() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      FadePageRoute(page: const WelcomeScreen()),
      (route) => false,
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Registration?'),
        content: const Text(
          'Your account will be deleted and you\'ll need to sign up again. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
              } catch (_) {
                // User might already be deleted or token expired
              }
              _navigateToWelcome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Registration', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: const Color(0xFFB4A5A5),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Email icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE3D8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: Color(0xFFB4A5A5),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification link to:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Email address
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInstructionRow(1, 'Open your email inbox'),
                      const SizedBox(height: 12),
                      _buildInstructionRow(2, 'Click the verification link'),
                      const SizedBox(height: 12),
                      _buildInstructionRow(3, 'Come back here'),
                    ],
                  ),
                ),

                const Spacer(),

                // Check verification button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _manualCheckVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4C4A8),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                            ),
                          )
                        : const Text(
                            'I\'VE VERIFIED MY EMAIL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend email button
                TextButton(
                  onPressed: (_canResend && !_isResending) ? _resendVerificationEmail : null,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        )
                      : Text(
                          _canResend
                              ? 'Resend Verification Email'
                              : 'Resend in ${_resendCooldown}s',
                          style: TextStyle(
                            color: _canResend ? Colors.white : Colors.white54,
                            fontSize: 16,
                            decoration: _canResend ? TextDecoration.underline : null,
                          ),
                        ),
                ),

                const SizedBox(height: 8),

                // Cancel button
                TextButton(
                  onPressed: _showCancelDialog,
                  child: const Text(
                    'Cancel Registration',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Auto-check indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Checking automatically...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(int step, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFD4C4A8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
