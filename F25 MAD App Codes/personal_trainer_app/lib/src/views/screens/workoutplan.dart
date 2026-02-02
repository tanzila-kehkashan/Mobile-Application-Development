import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// --- Import navigation screens ---
import 'dashboard.dart';
import 'profile.dart';
import 'schedule.dart';
import 'settings.dart';
import 'notifications.dart';
import 'workout_details.dart'; // <--- Ensure this import exists!

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1E35), // Dark Blue Background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to show the blue header behind it
        elevation: 0,
        // --- Custom Back Button ---
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back to Progress Screen
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          // --- Notification Bell ---
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20, top: 10),
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/notification_icon.png',
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      // We extend body behind AppBar so the blue header goes to the top
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // --- 1. Custom Blue Header Section ---
          Container(
            width: double.infinity,
            // Adjusted padding since tabs are gone
            padding: const EdgeInsets.only(top: 110, bottom: 40, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF64C8D6), // The Cyan/Light Blue header color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WORKOUT PLANS",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                // Removed the Tabs Row here
              ],
            ),
          ),

          // --- 2. List of Workout Cards ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPlanCard(
                    context,
                    title: "ADVANCED:",
                    subtitle: "UPPER BODY STRENGTH",
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    context,
                    title: "BEGINNER:",
                    subtitle: "CORE AND CARDIO",
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    context,
                    title: "INTERMEDIATE:",
                    subtitle: "LEG DAY POWER",
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Bottom Navigation Bar ---
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
                _buildNavItem(context, Icons.settings, "Setting", false),
                _buildNavItem(context, Icons.calendar_month, "Schedule", false),
                _buildNavItem(context, Icons.person, "Your Profile", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper: Workout Plan Card ---
  static Widget _buildPlanCard(BuildContext context, {required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailsScreen(planName: title),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF7F8C9A), // Grey-ish blue color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper: Bottom Nav (Working Logic) ---
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
        } else if (label == "Setting") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
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