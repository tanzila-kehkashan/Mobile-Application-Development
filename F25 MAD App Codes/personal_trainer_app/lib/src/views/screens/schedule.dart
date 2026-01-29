import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// --- Import all navigation screens ---
import 'dashboard.dart';
import 'profile.dart';
import 'settings.dart';
import 'notifications.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // --- STATE VARIABLES ---
  DateTime _selectedDate = DateTime.now(); // Tracks the currently selected day

  // --- DUMMY DATA FOR TASKS (Linked to Weekday) ---
  // 1 = Mon, 2 = Tue, ... 7 = Sun
  final Map<int, List<Map<String, String>>> _weeklySchedule = {
    1: [ // Monday
      {"time": "07:00 AM", "title": "Morning Yoga", "duration": "30 min"},
      {"time": "05:00 PM", "title": "Chest & Triceps", "duration": "50 min"},
    ],
    2: [ // Tuesday
      {"time": "08:00 AM", "title": "Cardio Blast", "duration": "40 min"},
      {"time": "06:00 PM", "title": "Back & Biceps", "duration": "60 min"},
    ],
    3: [ // Wednesday
      {"time": "07:30 AM", "title": "Pilates", "duration": "45 min"},
      {"time": "05:00 PM", "title": "Leg Day (Squats)", "duration": "60 min"},
    ],
    4: [ // Thursday
      {"time": "06:00 AM", "title": "HIIT Sprint", "duration": "30 min"},
      {"time": "05:30 PM", "title": "Shoulders & Abs", "duration": "50 min"},
    ],
    5: [ // Friday
      {"time": "07:00 AM", "title": "Full Body Stretch", "duration": "20 min"},
      {"time": "04:00 PM", "title": "CrossFit Session", "duration": "1 hour"},
    ],
    6: [ // Saturday
      {"time": "09:00 AM", "title": "Outdoor Run", "duration": "5 km"},
    ],
    7: [ // Sunday
      {"time": "10:00 AM", "title": "Rest & Recovery", "duration": "All Day"},
    ],
  };

  // --- HELPER: Get Month Name ---
  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  // --- HELPER: Get Weekday Name ---
  String _getDayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Get tasks for the selected date (or empty list if none)
    List<Map<String, String>> todaysTasks = _weeklySchedule[_selectedDate.weekday] ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
              margin: const EdgeInsets.only(right: 20),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- 1. DYNAMIC CALENDAR SECTION ---
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF152A45),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            // Shows: "December 2025" (Dynamic)
                            Text(
                              "${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),

                            // Horizontal Scrollable Days
                            SizedBox(
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 14, // Show next 2 weeks
                                itemBuilder: (context, index) {
                                  // Calculate date for this item
                                  DateTime date = DateTime.now().add(Duration(days: index));
                                  bool isSelected = date.day == _selectedDate.day &&
                                      date.month == _selectedDate.month;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            _getDayName(date.weekday),
                                            style: TextStyle(
                                              color: isSelected ? Colors.cyan : Colors.white54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 35,
                                            height: 35,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.cyan : Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: isSelected ? null : Border.all(color: Colors.white24),
                                            ),
                                            child: Text(
                                              "${date.day}",
                                              style: TextStyle(
                                                color: isSelected ? Colors.black : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- 2. TASK LIST HEADER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tasks for Today",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // Add Button (Visual only)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.cyan),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // --- 3. DYNAMIC TASK LIST ---
                      todaysTasks.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text("No tasks for this day. Rest easy!", style: TextStyle(color: Colors.white54)),
                      )
                          : ListView.builder(
                        shrinkWrap: true, // Important for nested listview
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todaysTasks.length,
                        itemBuilder: (context, index) {
                          final task = todaysTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildTaskItem(
                                task["time"]!,
                                task["title"]!,
                                task["duration"]!
                            ),
                          );
                        },
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
                    _buildNavItem(context, Icons.calendar_month, "Schedule", true), // Active
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
        } else if (label == "Setting") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        } else if (label == "Your Profile") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
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

  // --- Helper: Task Item Widget ---
  Widget _buildTaskItem(String time, String title, String duration) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Time Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 15),

          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white54, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Check/Arrow Icon
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}