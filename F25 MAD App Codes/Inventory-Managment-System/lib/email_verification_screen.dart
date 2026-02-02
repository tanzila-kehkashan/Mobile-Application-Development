import 'package:flutter/material.dart';
import 'dart:async';
import 'services/auth_service.dart';
import 'Login_page.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  bool _isResending = false;
  Timer? _timer;
  int _resendCooldown = 0;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Check email verification status every 3 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    bool verified = await authService.reloadAndCheckEmailVerified();
    if (verified && mounted) {
      setState(() {
        _isEmailVerified = true;
      });
      _timer?.cancel();

      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      await authService.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail || _isResending) return;

    setState(() => _isResending = true);

    try {
      await authService.sendEmailVerification();

      setState(() {
        _canResendEmail = false;
        _resendCooldown = 60;
        _isResending = false;
      });

      // Start cooldown timer
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown > 0) {
          if (mounted) {
            setState(() {
              _resendCooldown--;
            });
          }
        } else {
          timer.cancel();
          if (mounted) {
            setState(() {
              _canResendEmail = true;
            });
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() => _isResending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Verification?'),
        content: const Text(
          'You can continue without verifying your email, but some features may be limited. You can verify later from your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenSize.height < 700;

    // Responsive sizing
    final iconSize = screenWidth * 0.15;
    final titleSize = screenWidth * 0.06 > 28 ? 28.0 : screenWidth * 0.06;
    final bodySize = screenWidth * 0.035 > 14 ? 14.0 : screenWidth * 0.035;
    final buttonHeight = isSmallScreen ? 48.0 : 55.0;
    final padding = screenWidth * 0.06 > 24 ? 24.0 : screenWidth * 0.06;
    final spacing = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: spacing),

                            // Email Icon with animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(iconSize * 0.3),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6A99E0,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mark_email_unread_outlined,
                                  size: iconSize,
                                  color: const Color(0xFF6A99E0),
                                ),
                              ),
                            ),

                            SizedBox(height: spacing),

                            // Title
                            Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: spacing * 0.5),

                            // Subtitle
                            Text(
                              'We\'ve sent a verification email to:',
                              style: TextStyle(
                                fontSize: bodySize,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: spacing * 0.3),

                            // Email
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                              ),
                              child: Text(
                                widget.email,
                                style: TextStyle(
                                  fontSize: bodySize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6A99E0),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),

                            SizedBox(height: spacing),

                            // Instructions Card
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.all(padding * 0.7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStep(
                                    '1',
                                    'Open your email inbox',
                                    bodySize,
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  _buildStep(
                                    '2',
                                    'Click the verification link',
                                    bodySize,
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  _buildStep(
                                    '3',
                                    'Return here to login',
                                    bodySize,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: spacing),

                            // Loading indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Waiting for verification...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: bodySize * 0.9,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: spacing),

                            // Resend Button
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: OutlinedButton(
                                onPressed: _canResendEmail
                                    ? _resendVerificationEmail
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _canResendEmail
                                        ? const Color(0xFF6A99E0)
                                        : Colors.grey,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _canResendEmail
                                        ? 'Resend Verification Email'
                                        : 'Resend in $_resendCooldown seconds',
                                    key: ValueKey(_canResendEmail),
                                    style: TextStyle(
                                      color: _canResendEmail
                                          ? const Color(0xFF6A99E0)
                                          : Colors.grey,
                                      fontSize: bodySize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: spacing * 0.5),

                            // Skip for Now Button
                            TextButton(
                              onPressed: _skipVerification,
                              child: Text(
                                'Skip for Now',
                                style: TextStyle(
                                  color: const Color(0xFF6A99E0),
                                  fontSize: bodySize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Back to Login
                            TextButton(
                              onPressed: () async {
                                await authService.signOut();
                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              child: Text(
                                'Back to Login',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: bodySize * 0.9,
                                ),
                              ),
                            ),

                            SizedBox(height: spacing),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text, double fontSize) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6A99E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize * 0.9, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
