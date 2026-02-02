import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- ACTIVE IMPORTS ---
import 'change_password.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'schedule.dart';
import 'edit_profile.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'progress.dart';
import 'about_app.dart';
import 'help.dart';
import 'logout.dart'; // <--- THIS IMPORT IS CRITICAL
import 'rattings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // defining the list of settings
    final List<Map<String, dynamic>> settingsItems = [
      {
        'title': 'Edit Profile',
        'icon': Icons.person_outline,
        'screen': const EditProfileScreen(),
      },
      {
        'title': 'Your Goals',
        'icon': Icons.show_chart,
        'screen': const ProgressScreen(),
      },
      {
        'title': 'Your Schedule',
        'icon': Icons.calendar_today_outlined,
        'screen': const ScheduleScreen(),
      },
      {
        'title': 'Change Password',
        'icon': Icons.lock_outline,
        // OLD CODE (Might be ForgotPasswordScreen)
        'screen': const ForgotPasswordScreen(),
      },
      {
        'title': 'Add an Account',
        'icon': Icons.person_add_alt,
        'screen': const SignUpScreen(),
      },
      {
        'title': 'Rate Us',
        'icon': Icons.star_border,
        'screen': const RattingsScreen(),
      },
      {
        'title': 'Help',
        'icon': Icons.help_outline,
        'screen': const HelpScreen(),
      },
      {
        'title': 'About App',
        'icon': Icons.info_outline,
        'screen': const AboutAppScreen(),
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        // If 'const' still gives an error, remove the word 'const'
        // But with my previous code, 'const' should work.
        'screen': const LogoutScreen(),
        'isDestructive': true,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. LIST OF SETTINGS ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: settingsItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final item = settingsItems[index];
                    final isDestructive = item['isDestructive'] == true;

                    // --- STANDARD SETTINGS ITEM ---
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1E35).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          item['icon'],
                          color: isDestructive ? Colors.redAccent : Colors.cyan,
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            color: isDestructive ? Colors.redAccent : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white54
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => item['screen']),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // --- 2. BOTTOM NAVIGATION BAR ---
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1E35),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.fitness_center, "Dashboard", false),
                    _buildNavItem(context, Icons.settings, "Setting", true), // Active
                    _buildNavItem(context, Icons.calendar_month, "Schedule", false),
                    _buildNavItem(context, Icons.person, "Your Profile", false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Bottom Nav Logic ---
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "Dashboard") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else if (label == "Your Profile") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (label == "Schedule") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ScheduleScreen()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? Colors.cyan : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.cyan : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}