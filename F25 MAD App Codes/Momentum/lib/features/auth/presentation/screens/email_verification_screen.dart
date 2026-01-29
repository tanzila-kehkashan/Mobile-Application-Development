import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/features/home/presentation/screens/dashboard_screen.dart';
import 'package:momentum/features/auth/presentation/screens/login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 3 seconds
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification(showMessage: false);
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification({bool showMessage = true}) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    final appState = AppStateProvider.of(context);
    await appState.authService.reloadUser();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (appState.authService.isEmailVerified) {
      _autoCheckTimer?.cancel();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(page: const DashboardScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } else if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    if (_isResending || _resendCooldown > 0) return;
    
    setState(() => _isResending = true);

    final appState = AppStateProvider.of(context);
    final result = await appState.authService.sendEmailVerification();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result.success) {
      // Start cooldown timer (60 seconds)
      setState(() => _resendCooldown = 60);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown <= 0) {
          timer.cancel();
        } else {
          setState(() => _resendCooldown--);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to send verification email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCancel() async {
    final appState = AppStateProvider.of(context);
    await appState.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      FadePageRoute(page: const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _handleCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3D7E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 60,
                color: Color(0xFFE8FF78),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Verify Your Email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification link to',
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(
                color: Color(0xFFE8FF78),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3D7E).withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Click the link in the email to verify your account. Check spam folder if not found.',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _checkVerification(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8FF78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'I\'ve Verified My Email',
                        style: TextStyle(
                          color: Color(0xFF201A3F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: (_isResending || _resendCooldown > 0) ? null : _resendVerification,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: _isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : 'Resend Verification Email',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.autorenew, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Auto-checking verification status...',
                  style: TextStyle(
                    color: Colors.white.withAlpha(97),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
