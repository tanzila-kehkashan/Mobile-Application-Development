import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'logout.dart'; // 1. Import the Logout Screen
import 'forgotPassword_screen.dart'; // Import ForgotPassword Screen

class SettingsScreen extends StatelessWidget {
  static const String _backgroundImagePath = 'assets/images/background.png';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_backgroundImagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.shade400,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.white),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: Icons.person_outline,
                          text: 'Profile',
                          color: Colors.tealAccent.shade400,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 12.0),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          text: 'About Quizzy',
                          color: Colors.tealAccent.shade400,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12.0),
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          text: 'Help Center',
                          color: Colors.tealAccent.shade400,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpCentreScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12.0),
                        
                        // 2. RESET PASSWORD
                        _buildSettingsItem(


                          icon: Icons.help_outline, 
                          text: 'Reset Password',
                          color: Colors.tealAccent.shade400,
                          onTap: () {
                            final user = FirebaseAuth.instance.currentUser;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(email: user?.email),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12.0),

                        // 3. LOGOUT NAVIGATION
                        _buildSettingsItem(
                          icon: Icons.logout,
                          text: 'Logout',
                          color: Colors.tealAccent.shade400,
                          onTap: () {
                            // Navigate to the separate Logout Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogoutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      elevation: 2.0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28.0),
              const SizedBox(width: 16.0),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.black54, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}