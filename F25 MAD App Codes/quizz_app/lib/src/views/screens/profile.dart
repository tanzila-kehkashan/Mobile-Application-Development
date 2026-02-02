import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizz_app/services/auth_service.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/user_score_model.dart';
import 'package:quizz_app/src/models/quiz_history_model.dart';
import 'settings.dart'; // Import settings screen
import 'Discover_screen.dart'; // Import Discover Screen
import 'leaderboard.dart'; // Import Leaderboard Screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _backgroundImagePath = 'assets/images/background.png';
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService(); // Add AuthService
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    if (currentUserId != null) {
      _quizService.syncQuizzesPlayedCount(currentUserId!);
    }
  }

  // ... (build method remains mostly same until body)


  // Add this method
  void _showEditProfileDialog(String currentName) {
    final TextEditingController _nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Profile", style: TextStyle(color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Display Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Avatar selection coming soon!", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A5ACD)),
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    // Update Auth Profile
                    await _authService.updateDisplayName(newName);
                    
                    // Update Leaderboard Name
                    if (currentUserId != null) {
                      await _quizService.updateUserName(currentUserId!, newName);
                    }
                    
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {}); // Refresh UI
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                  }
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Update _buildAvatar to be clickable
  Widget _buildAvatar(String currentName) { // Accept currentName to pass to dialog
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.purple[200]!,
          child: const Icon(Icons.face_3, size: 55, color: Colors.white),
        ),
        Positioned(
          bottom: 0,
          right: -5,
          child: GestureDetector(
            onTap: () => _showEditProfileDialog(currentName),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.tealAccent.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
            actions: [
               IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Use StreamBuilder to get real data
          body: StreamBuilder<List<UserScore>>(
            stream: _quizService.getLeaderboard(),
            builder: (context, snapshot) {
              String name = "User";
              String points = "0";
              String rank = "-";
              String quizzesPlayed = "0"; // New variable

              if (snapshot.hasData) {
                final leaderboard = snapshot.data!;
                // Find current user's entry
                
                int userIndex = -1;
                UserScore? myScore;

                if (currentUserId != null) {
                  for (int i = 0; i < leaderboard.length; i++) {
                    if (leaderboard[i].userId == currentUserId) {
                       userIndex = i;
                       myScore = leaderboard[i];
                       break;
                    }
                  }
                }

                if (myScore != null) {
                   name = myScore.userName;
                   points = myScore.score.toString();
                   rank = "#${userIndex + 1}";
                   quizzesPlayed = myScore.quizzesPlayed.toString(); // Get value
                } else {
                   // User not in top list or has 0 score, try to show email
                   name = (FirebaseAuth.instance.currentUser?.displayName) ?? 
                          (currentUserEmail?.split('@')[0] ?? "User");
                }
              }

              return Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildAvatar(name),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildStatsBox(points, rank, quizzesPlayed), // Pass new arg
                              const SizedBox(height: 24),
                              // Recent History Section
                              Container(
                                width: double.infinity,
                                child: Text(
                                  "Recent History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (currentUserId != null)
                                StreamBuilder<List<QuizHistory>>(
                                  stream: _quizService.getQuizHistory(currentUserId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                       return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20.0),
                                        child: Text("No quizzes played yet.", style: TextStyle(color: Colors.grey)),
                                      );
                                    }
                                    
                                    final historyList = snapshot.data!;
                                    return Column(
                                      children: historyList.map((history) => _buildHistoryItem(history)).toList(),
                                    );
                                  },
                                )
                              else
                                 const Text("Log in to see history"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
          bottomNavigationBar: _buildBottomNavBar(context),
        ),
      ],
    );
  }



  Widget _buildHistoryItem(QuizHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.quizTitle, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "${history.timestamp.day}/${history.timestamp.month}/${history.timestamp.year}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
               Text(
                "${history.score}/${history.totalQuestions}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () {
                  _showDeleteConfirmDialog(history.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String historyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete History"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              if (currentUserId != null) {
                 await _quizService.deleteQuizHistory(currentUserId!, historyId);
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("History item deleted!"), duration: Duration(seconds: 2)),
                   );
                 }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBox(String points, String rank, String quizzesPlayed) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.tealAccent.shade400,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(Icons.star, 'POINTS', points),
            const VerticalDivider(color: Colors.white54, thickness: 1),
            _buildStatItem(Icons.public, 'WORLD RANK', rank),
            const VerticalDivider(color: Colors.white54, thickness: 1),
            _buildStatItem(Icons.play_circle_filled, 'QUIZZES', quizzesPlayed), // New Stat
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 3,
        selectedItemColor: const Color(0xFF6A5ACD),
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          } else if (index == 1) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DiscoverScreen()));
          } else if (index == 2) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
          }
        },
      ),
    );
  }
}