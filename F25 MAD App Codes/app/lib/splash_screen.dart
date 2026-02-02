import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/home_screen.dart';
import 'package:nexus/email_verification_screen.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Hide status bar for immersive splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Check auth state after splash animation
    Timer(const Duration(seconds: 2), _checkAuthState);
  }

  void _checkAuthState() {
    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      // Restore status bar before navigating
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      if (user != null) {
        // Check if email is verified
        if (user.emailVerified) {
          // User is logged in and verified, go to home
          Navigator.of(context).pushReplacement(
            FadePageRoute(page: const HomeScreen()),
          );
        } else {
          // User exists but email not verified, go to verification screen
          Navigator.of(context).pushReplacement(
            FadePageRoute(page: const EmailVerificationScreen()),
          );
        }
      } else {
        // User is not logged in, go to welcome with fade transition
        Navigator.of(context).pushReplacement(
          FadePageRoute(page: const WelcomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB5AAAC),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo from assets
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // NEXUS Text
                    const Text(
                      'NEXUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The Nexus of Alumni',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
