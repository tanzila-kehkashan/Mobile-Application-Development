import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:quizz_app/services/auth_service.dart'; // Import AuthService
import 'package:quizz_app/src/views/screens/adminDashboard.dart'; // Import AdminDashboard
import 'profile.dart';
import 'Discover_screen.dart';
import 'leaderboard.dart';
import 'quiz_screen.dart'; // Import Quiz Screen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final QuizService _quizService = QuizService(); // Instance of QuizService
  final AuthService _authService = AuthService();
  bool _isAdmin = false;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadUserName();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Auto-repair: Ensure user document exists
      _authService.createUserDocument(user.uid, user.email ?? "").catchError((e) {
        debugPrint("Auto-repair user doc error: $e");
      });

      if (mounted) {
        setState(() {
          _userName = user.displayName ?? user.email?.split('@')[0] ?? "User";
        });
      }
    }
  }

  Future<void> _checkUserRole() async {
    final user = _authService.currentUser;
    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      if (mounted) {
        setState(() {
          _isAdmin = role == 'admin';
        });
      }
    }
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "GOOD MORNING";
    } else if (hour < 17) {
      return "GOOD AFTERNOON";
    } else {
      return "GOOD EVENING";
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscoverScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() { _selectedIndex = index; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Container(
            height: 350,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              _buildTopHeader(),
              // _buildRecentQuizCard(), // Start hidden to avoid confusion
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 300),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _buildLiveQuizzesList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
              backgroundColor: const Color(0xFF6A5ACD),
               icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              label: const Text("Admin", style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTopHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Placeholder for alignment
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                    .then((_) => _loadUserName());
                  },
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE6E6FA),
                    child: Icon(Icons.person, size: 30, color: Color(0xFF6A5ACD)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(_getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
             StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(), 
              builder: (context, snapshot) {
                 final user = snapshot.data;
                 final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? "User";
                 return Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold));
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveQuizzesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: Text("Live Quizzes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Expanded(
          child: StreamBuilder<List<Quiz>>(
            stream: _quizService.getQuizzes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No quizzes available'));
              }

              final quizzes = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  // Map iconName String to IconData
                  IconData iconData = Icons.article; // Default
                  if (quiz.iconName == 'sports_soccer') iconData = Icons.sports_soccer;
                  if (quiz.iconName == 'music_note') iconData = Icons.music_note;
                  if (quiz.iconName == 'science') iconData = Icons.science;
                  // Add more mappings as needed

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                         // Convert Quiz object back to Map for QuizScreen if needed
                         final quizMap = {
                           'title': quiz.title,
                           'subtitle': quiz.subtitle,
                           'icon': iconData,
                           'iconColor': Color(quiz.colorHex),
                           'bgColor': Color(quiz.colorHex).withOpacity(0.2), // Approx
                         };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              quizContent: quizMap,
                              quizId: quiz.id, // Pass quiz.id
                            ),
                          ),
                        );
                      },
                      child: _buildQuizItem(
                        icon: iconData,
                        title: quiz.title,
                        subtitle: quiz.subtitle,
                        iconColor: Color(quiz.colorHex),
                        iconBackgroundColor: Color(quiz.colorHex).withOpacity(0.1),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizItem({required IconData icon, required String title, required String subtitle, required Color iconColor, required Color iconBackgroundColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBackgroundColor, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 10)],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6A5ACD),
        unselectedItemColor: Colors.grey.shade400,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}