import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- NAVIGATION IMPORTS ---
import 'dashboard.dart';
import 'profile.dart';
import 'schedule.dart';
import 'settings.dart';
import 'notifications.dart';
import 'diet_details.dart'; // <--- Connects to the details screen

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1E35), // Dark Blue Background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset('assets/images/back_icon.png', fit: BoxFit.contain),
          ),
        ),
        actions: [
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
      ),
      body: Column(
        children: [
          // --- 1. Header Section ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 100, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF64C8D6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DIET PLANS",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Choose your level",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Icon
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset("assets/images/nutrition icon.png",
                    fit: BoxFit.contain,
                    errorBuilder: (c,o,s) => const Icon(Icons.restaurant, size: 60, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. Diet Cards ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDietCard(
                    context,
                    title: "BEGINNER",
                    subtitle: "WEIGHT LOSS & DETOX",
                  ),
                  const SizedBox(height: 20),
                  _buildDietCard(
                    context,
                    title: "INTERMEDIATE",
                    subtitle: "BALANCED MACROS",
                  ),
                  const SizedBox(height: 20),
                  _buildDietCard(
                    context,
                    title: "ADVANCED",
                    subtitle: "HIGH PROTEIN BULK",
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Bottom Navigation ---
          Container(
            height: 80,
            color: const Color(0xFF0A1E35),
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

  // --- Helper: Diet Plan Card ---
  Widget _buildDietCard(BuildContext context, {required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () {
        // FIXED: Changed "DietDetailScreen" to "DietDetailsScreen" (with an 's')
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DietDetailsScreen(planName: title),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF7F8C9A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title:",
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

  // --- Helper: Bottom Nav ---
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "Dashboard") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        if (label == "Your Profile") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        if (label == "Setting") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        if (label == "Schedule") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScheduleScreen()));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.cyan : Colors.grey),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: isActive ? Colors.cyan : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}