import 'package:flutter/material.dart';

// IMPORTANT: Import your other screens here
import 'package:nexus/services/auth_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'color_change_screen.dart';
import 'about_app_screen.dart';
import 'login_screen.dart';
import 'user_details_screen.dart';
import 'home_screen.dart';
import 'contact_screen.dart';
import 'jobs_feed_screen.dart';
import 'event_calendar_screen.dart';
import 'chat_list_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

// Custom colors derived from the Figma design
const Color _backgroundColor = Color(0xFFEBE3E3);
const Color _foregroundColor = Colors.black87;
const Color _buttonColor = Color(0xFFCBB8A1);
const Color _closeIconColor = Color(0xFF5A4C6B);

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Helper widget to build each menu list item with animation
  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required String title,
    required int index,
    bool isColorful = false,
    VoidCallback? onTap,
  }) {
    return FadeSlideAnimation(
      delay: Duration(milliseconds: 150 + (index * 80)),
      beginOffset: const Offset(-0.3, 0),
      child: ScaleOnTap(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                icon,
                color: _foregroundColor,
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: _foregroundColor,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: _foregroundColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the custom Sign Out Dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: FadeSlideAnimation(
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Title
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                        child: Text(
                          'Sign out ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _foregroundColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Subtext
                      const Padding(
                        padding: EdgeInsets.only(bottom: 30.0),
                        child: Text(
                          'If you answer yes, you will be signed\nout from the app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _foregroundColor,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Yes Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ScaleOnTap(
                          onTap: () async {
                            // 1. Close the dialog
                            Navigator.of(dialogContext).pop();

                            // 2. Sign out from Firebase
                            await AuthService().signOut();

                            // 3. Navigate to Login Screen
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadePageRoute(page: const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _buttonColor,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // No Button
                      ScaleOnTap(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _foregroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                  // Close/X Icon Button
                  Positioned(
                    top: -10,
                    right: -10,
                    child: ScaleOnTap(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _closeIconColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: _closeIconColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _foregroundColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Large White Graduation Cap Icon with animation
            ScaleAnimation(
              delay: const Duration(milliseconds: 100),
              child: const Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 60.0),
                child: Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),

            // 2. Menu Items List with staggered animations
            _buildAnimatedMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              index: 0,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const UserDetailsScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.border_color,
              title: 'Home Feed',
              index: 1,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const HomeScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.work_outline,
              title: 'Jobs',
              index: 2,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const JobsFeedScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              index: 3,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const ChatListScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.menu_book_outlined,
              title: 'Events',
              index: 4,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const EventCalendarScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.palette_outlined,
              title: 'Colours',
              index: 5,
              isColorful: true,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const ColorChangeScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.contact_page_outlined,
              title: 'Contact',
              index: 6,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const ContactScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.search,
              title: 'Search',
              index: 7,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const SearchScreen()),
                );
              },
            ),

            _buildAnimatedMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              index: 8,
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const SettingsScreen()),
                );
              },
            ),

            const SizedBox(height: 40),

            // 3. Sign Out Button with animation
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 900),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                height: 55,
                child: ScaleOnTap(
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: _foregroundColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: _foregroundColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 4. ABOUT APP Text with animation
            FadeAnimation(
              delay: const Duration(milliseconds: 1000),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const AboutAppScreen()),
                  );
                },
                child: const Text(
                  'ABOUT APP',
                  style: TextStyle(
                    fontSize: 16,
                    color: _foregroundColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: _foregroundColor,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
