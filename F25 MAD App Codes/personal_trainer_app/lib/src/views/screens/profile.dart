import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Database
import 'package:firebase_auth/firebase_auth.dart';     // Auth

// --- Import all navigation screens ---
import 'dashboard.dart';
import 'settings.dart';
import 'schedule.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),
        ],
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
          // 2. REAL-TIME DATA FETCHER
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {

              // Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error or No Data State
              if (!snapshot.hasData || snapshot.data?.data() == null) {
                return const Center(child: Text("No Profile Data Found", style: TextStyle(color: Colors.white)));
              }

              // 3. Get Data from Database
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String name = userData['fullName'] ?? 'User';
              String age = userData['age'] ?? '--';
              String height = userData['height'] ?? '--';
              String weight = userData['weight'] ?? '--';

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // --- Profile Picture ---
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.cyan, width: 3),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/profile_logo.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // --- Name & Title ---
                          Text(
                            name, // <--- Shows real name from Firebase
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Lose a Fat Program',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- Edit Profile Button ---
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                            child: Container(
                              width: 160,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- Stats Row (Shows real data) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ProfileStat(label: "Height", value: height),
                              _ProfileStat(label: "Weight", value: weight),
                              _ProfileStat(label: "Age", value: "$age yo"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- BOTTOM NAVIGATION BAR ---
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
                        _buildNavItem(context, Icons.person, "Your Profile", true),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Navigation Helper ---
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "Dashboard") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
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

// --- Helper for Stats ---
class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}