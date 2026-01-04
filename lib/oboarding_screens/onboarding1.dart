import 'package:flutter/material.dart';

import '../auth_screens/login.dart';
import '../nav_bar.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      image: 'assets/images/iPhoneX1.png',
      title: 'Explore Upcoming and Nearby Events',
      description: 'In publishing and graphic design, Lorem is a placeholder text commonly',
    ),
    OnboardingData(
      image: 'assets/images/iPhoneX2.png', // Add your second image
      title: 'Web Have Modern Events Calendar Feature',
      description: 'In publishing and graphic design, Lorem is a placeholder text commonly',
    ),
    OnboardingData(
      image: 'assets/images/iPhoneX3.png', // Add your third image
      title: 'To Look Up More Events or Activities Nearby By Map',
      description: 'In publishing and graphic design, Lorem is a placeholder text commonly',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _skipOnboarding() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(), // Changed from DummyHomeScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep safe area to avoid status bar overlap
      body: SafeArea(
        child: Column(
          children: [
            // Preview of the app screen
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  // Use ClipRRect to apply rounded corners AND ensure the image
                  // scales to the available space (prevent overflow).
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      // SizedBox.expand gives the child the container constraints,
                      // and Image.asset with BoxFit.contain/cover prevents overflow.
                      child: SizedBox.expand(
                        child: Image.asset(
                          _onboardingPages[index].image,
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                          height: double.infinity,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Onboarding Content with rounded top edges
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B4EFF), Color(0xFF4E7FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                // Use LayoutBuilder + SingleChildScrollView + ConstrainedBox + IntrinsicHeight
                // to avoid overflow on small screens while keeping content centered when possible.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _onboardingPages[_currentPage].title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _onboardingPages[_currentPage].description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                // Dots Indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _onboardingPages.length,
                                        (index) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: _buildDot(_currentPage == index),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Spacer to push buttons to bottom when there's extra space
                                const Spacer(),
                                // Navigation Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: _skipOnboarding,
                                      child: const Text(
                                        'Skip',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        (_currentPage == _onboardingPages.length - 1)
                                            ? _skipOnboarding()
                                            : _nextPage();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF5B4EFF),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: Text(
                                        _currentPage == _onboardingPages.length - 1
                                            ? 'Get Started'
                                            : 'Next',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}