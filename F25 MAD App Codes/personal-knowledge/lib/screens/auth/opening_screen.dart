import 'package:flutter/material.dart';
import 'signup_choice_screen.dart';
import 'login_screen.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: responsive.padding(mobile: 60, tablet: 80)),

              // Animated Icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Icon(
                    Icons.auto_awesome,
                    size: AppSizes.iconXL(context),
                    color: const Color(0xFF007AFF),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.paddingL(context)),

              // Animated Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Explore the app',
                    style: TextStyle(
                      fontSize: AppSizes.fontXL(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.spaceM(context)),

              // Animated Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Keep your finances in one place and always under control.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizes.fontS(context),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive.padding(mobile: 40, tablet: 60)),

              // Animated Sign In Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(page: const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      responsive.buttonHeight(mobile: 48, tablet: 56),
                    ),
                  ),
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontSize: AppSizes.fontM(context)),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.spaceM(context)),

              // Animated Create Account Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(page: SignupChoiceScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      responsive.buttonHeight(mobile: 48, tablet: 56),
                    ),
                  ),
                  child: Text(
                    "Create account",
                    style: TextStyle(fontSize: AppSizes.fontM(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}