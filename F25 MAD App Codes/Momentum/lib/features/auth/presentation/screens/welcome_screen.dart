import 'package:flutter/material.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';
import 'package:momentum/features/auth/presentation/screens/login_screen.dart';
import 'package:momentum/features/auth/presentation/screens/register_screen.dart';
import 'package:momentum/features/home/presentation/screens/dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Animated logo
            AnimatedScaleIn(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child: Image.asset('assets/images/logo.png', height: 120),
            ),
            const SizedBox(height: 50),
            // Animated text
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                'Start your',
                style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                  color: Colors.white,
                ),
              ),
            ),
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 350),
              child: const Text(
                'Fitness Journey',
                style: TextStyle(
                  fontFamily: 'Montserrat Alternates',
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                  color: Color(0xFFE8FF78),
                ),
              ),
            ),
            const Spacer(flex: 3),
            // Animated buttons
            AnimatedListItem(
              index: 0,
              delay: const Duration(milliseconds: 100),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3D7E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedListItem(
              index: 1,
              delay: const Duration(milliseconds: 100),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                        color: Color(0xFF201A3F),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedListItem(
              index: 2,
              delay: const Duration(milliseconds: 100),
              child: TextButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      FadePageRoute(page: const DashboardScreen()),
                    );
                },
                child: const Text(
                  'Continue as a guest',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
