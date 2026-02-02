import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// --- IMPORTS ---
import 'workout_details.dart';
import 'profile.dart';
import 'schedule.dart';
import 'settings.dart';
import 'notifications.dart';
import 'progress.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "User";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- VARIABLES FOR REAL-TIME SESSION ---
  String _nextSessionTime = "Loading...";
  String _nextSessionTitle = "LOADING...";
  String _nextSessionKey = "MORNING"; // "MORNING" or "WEIGHT"

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _calculateNextSession(); // <--- Run logic on startup
  }

  // --- 1. LOGIC: Calculate Next Session based on Real Time ---
  void _calculateNextSession() {
    DateTime now = DateTime.now();
    int hour = now.hour; // 0 to 23

    setState(() {
      if (hour < 10) {
        // Before 10 AM -> Morning Session
        _nextSessionTime = "Today at 10:00 AM";
        _nextSessionTitle = "MORNING YOGA";
        _nextSessionKey = "MORNING";
      } else if (hour >= 10 && hour < 18) {
        // Between 10 AM and 6 PM -> Evening Session
        _nextSessionTime = "Today at 6:00 PM";
        _nextSessionTitle = "WEIGHT TRAINING";
        _nextSessionKey = "WEIGHT";
      } else {
        // After 6 PM -> Tomorrow Morning
        _nextSessionTime = "Tomorrow at 10:00 AM";
        _nextSessionTitle = "MORNING YOGA";
        _nextSessionKey = "MORNING";
      }
    });
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userName = userDoc['fullName'] ?? "User";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dashboard", style: TextStyle(color: Colors.white, fontSize: 14)),
              Text("Welcome back, $_userName", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          )
        ],
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // --- 2. UPDATED REAL-TIME SESSION CARD ---
                      GestureDetector(
                        onTap: () {
                          // Dynamic Navigation based on time
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WorkoutDetailsScreen(planName: _nextSessionKey))
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1E35).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Next Session at", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  const SizedBox(height: 5),
                                  // REAL TIME TEXT
                                  Text(
                                      _nextSessionTime,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // REAL PLAN TITLE
                                  Text(
                                      _nextSessionTitle,
                                      style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)
                                  ),
                                  const SizedBox(height: 5),
                                  const Text("45 min session >", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- START TRAINING BUTTON ---
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen()));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/button_gradient_bg.png'),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'START YOUR TRAINING NOW',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- GRAPH SECTION ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Your activity", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text("This Week", style: TextStyle(color: Colors.cyan, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        height: 200,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E35).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: user != null
                              ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('workouts')
                              .orderBy('timestamp', descending: true)
                              .limit(20)
                              .snapshots()
                              : null,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return _buildDynamicGraph(snapshot.data!.docs);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM NAVIGATION ---
              Container(
                height: 80,
                color: const Color(0xFF0A1E35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.fitness_center, "Dashboard", true),
                    _buildNavItem(context, Icons.settings, "Setting", false),
                    _buildNavItem(context, Icons.calendar_month, "Schedule", false),
                    _buildNavItem(context, Icons.person, "Profile", false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: Graph Builder ---
  Widget _buildDynamicGraph(List<QueryDocumentSnapshot> docs) {
    Map<int, double> weeklyCalories = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['timestamp'] != null) {
        DateTime date = (data['timestamp'] as Timestamp).toDate();
        weeklyCalories[date.weekday] = (weeklyCalories[date.weekday] ?? 0) + (data['calories'] as int? ?? 0);
      }
    }

    double maxCal = 0;
    weeklyCalories.forEach((k, v) {
      if (v > maxCal) maxCal = v;
    });
    if (maxCal == 0) maxCal = 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        int dayNum = index + 1;
        double value = weeklyCalories[dayNum] ?? 0;
        double barHeight = (value / maxCal) * 100;
        if (barHeight < 5) barHeight = 5;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.cyan, Colors.blue],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              days[index],
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "Setting") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        if (label == "Schedule") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScheduleScreen()));
        if (label == "Profile") Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
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