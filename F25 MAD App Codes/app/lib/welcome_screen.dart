import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4A5A5),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Column(
            children: [
              // App title - animate from left
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 100),
                beginOffset: const Offset(-0.3, 0),
                child: const Padding(
                  padding: EdgeInsets.only(top: 16, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'NEXUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Graduation cap icon - scale animation
              ScaleAnimation(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 100,
                    color: Color(0xFFB4A5A5),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Welcome text - fade slide up
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  'Hello , Welcome !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description text
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 600),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Welcome to Nexus Top\nplatform For University Student',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Login button - slide from bottom
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 750),
                beginOffset: const Offset(0, 0.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ScaleOnTap(
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const LoginScreen()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C4A8),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Signup button - slide from bottom
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 850),
                beginOffset: const Offset(0, 0.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ScaleOnTap(
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const SignupScreen()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C4A8),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Text(
                            'Signup',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Bottom indicator
              FadeAnimation(
                delay: const Duration(milliseconds: 1000),
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
    );
  }
}
