import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isChecking = false;
  bool _canResend = false;
  Timer? _timer;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Check email verification status periodically
    _checkEmailVerified();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerified() async {
    final authService = ref.read(authServiceProvider);
    
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isVerified = await authService.isEmailVerified();
      
      if (isVerified) {
        timer.cancel();
        if (mounted) {
          _showSnackBar('Email verified successfully!', isError: false);
          // Navigate to main app
          await Future.delayed(const Duration(seconds: 1));
          // The authStateProvider will handle navigation automatically
        }
      }
    });
  }

  Future<void> _resendVerification() async {
    final authService = ref.read(authServiceProvider);
    
    try {
      await authService.sendEmailVerification();
      _showSnackBar('Verification email sent!', isError: false);
      _startCountdown();
    } catch (e) {
      _showSnackBar('Failed to send verification email', isError: true);
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    final authService = ref.read(authServiceProvider);
    final isVerified = await authService.isEmailVerified();

    setState(() {
      _isChecking = false;
    });

    if (isVerified) {
      _showSnackBar('Email verified successfully!', isError: false);
      // The authStateProvider will handle navigation automatically
    } else {
      _showSnackBar('Email not verified yet. Please check your inbox.', isError: true);
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
    final user = ref.watch(authStateProvider).value;
    final email = user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Sign out and go back to login
            ref.read(authServiceProvider).signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Icon
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: Color(0xFF5B4EFF),
              ),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                "We've sent a verification link to\n$email",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please check your inbox and click the verification link to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Check Verification Button
              _isChecking
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4EFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _checkVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4EFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'I\'VE VERIFIED MY EMAIL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              // Resend Email
              Center(
                child: TextButton(
                  onPressed: _canResend ? _resendVerification : null,
                  child: Text(
                    _canResend
                        ? 'Resend Verification Email'
                        : 'Resend in $_countdown seconds',
                    style: TextStyle(
                      color: _canResend ? const Color(0xFF5B4EFF) : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Help Text
              const Text(
                'Didn\'t receive the email? Check your spam folder or try resending.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}