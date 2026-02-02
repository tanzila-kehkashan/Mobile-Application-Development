import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/services/auth_service.dart';
import 'package:quizz_app/services/help_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'package:quizz_app/src/views/screens/admin_quiz_details.dart';
import 'package:quizz_app/src/views/screens/admin_users_screen.dart';
import 'package:quizz_app/src/views/screens/admin_help_requests_screen.dart';
import 'package:quizz_app/src/views/screens/all_quizzes_screen.dart';
import 'package:quizz_app/src/views/screens/login.dart';
import 'addQuestionn_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();
  final HelpService _helpService = HelpService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3a3a3a),
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('ADMIN DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: StreamBuilder<List<Quiz>>(
          stream: _quizService.getQuizzes(),
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
             }

             final quizzes = snapshot.data ?? [];
             final totalQuizzes = quizzes.length;

             return Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 children: [
                   // --- STATS ROW 1 ---
                   FutureBuilder<int>(
                     future: _authService.getUserCount(),
                     builder: (context, userSnapshot) {
                       final totalUsers = userSnapshot.hasData ? userSnapshot.data.toString() : "-";
                       return Row(
                         children: [
                            _buildStatCard(
                              "Total Quizzes", 
                              totalQuizzes.toString(), 
                              Icons.library_books, 
                              Colors.orangeAccent,
                              onTap: () {
                                // Scroll to quiz list section
                                _scrollController.animateTo(
                                  400, // Approximate position of quiz list
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              "Total Users", 
                              totalUsers, 
                              Icons.people, 
                              Colors.purpleAccent,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUsersScreen()));
                              }
                            ),
                         ],
                       );
                     }
                   ),
                   const SizedBox(height: 16),
                   
                   // --- HELP REQUESTS CARD (Full Width Premium) ---
                   FutureBuilder<int>(
                     future: _helpService.getPendingRequestsCount(),
                     builder: (context, helpSnapshot) {
                       final pendingRequests = helpSnapshot.hasData ? helpSnapshot.data ?? 0 : 0;
                       return GestureDetector(
                         onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHelpRequestsScreen()));
                         },
                         child: Container(
                           padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [
                                 Colors.redAccent.withOpacity(0.8),
                                 Colors.deepOrangeAccent.withOpacity(0.8),
                               ],
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                             ),
                             borderRadius: BorderRadius.circular(16),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.redAccent.withOpacity(0.3),
                                 blurRadius: 12,
                                 offset: const Offset(0, 6),
                               ),
                             ],
                           ),
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withOpacity(0.2),
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: const Icon(
                                   Icons.support_agent,
                                   color: Colors.white,
                                   size: 32,
                                 ),
                               ),
                               const SizedBox(width: 16),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     const Text(
                                       'Help Requests',
                                       style: TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                         letterSpacing: 0.5,
                                       ),
                                     ),
                                     const SizedBox(height: 4),
                                     Text(
                                       pendingRequests == 0 
                                         ? 'No pending requests' 
                                         : '$pendingRequests pending ${pendingRequests == 1 ? "request" : "requests"}',
                                       style: TextStyle(
                                         fontSize: 13,
                                         color: Colors.white.withOpacity(0.9),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 child: Text(
                                   pendingRequests.toString(),
                                   style: const TextStyle(
                                     fontSize: 20,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.redAccent,
                                   ),
                                 ),
                               ),
                               const SizedBox(width: 8),
                               const Icon(
                                 Icons.arrow_forward_ios,
                                 color: Colors.white,
                                 size: 18,
                               ),
                             ],
                           ),
                         ),
                       );
                     }
                   ),
                   const SizedBox(height: 24),
                   
                   // --- QUIZ LIST HEADER ---
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         "Manage Quizzes", 
                         style: TextStyle(
                           fontSize: 18, 
                           fontWeight: FontWeight.bold, 
                           color: Colors.white70,
                         ),
                       ),
                       if (quizzes.length > 3)
                         TextButton.icon(
                           onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => const AllQuizzesScreen(),
                               ),
                             );
                           },
                           icon: const Icon(
                             Icons.arrow_forward,
                             color: Color(0xFF26E3BA),
                             size: 18,
                           ),
                           label: const Text(
                             'See All',
                             style: TextStyle(
                               color: Color(0xFF26E3BA),
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                     ],
                   ),
                   const SizedBox(height: 12),

                   // --- LIST (Max 3) ---
                   quizzes.isEmpty 
                   ? const Padding(
                       padding: EdgeInsets.all(40),
                       child: Center(child: Text("No quizzes found. Add one!", style: TextStyle(color: Colors.grey))),
                     )
                   : ListView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: quizzes.length > 3 ? 3 : quizzes.length,
                       itemBuilder: (context, index) {
                         return _buildQuizCard(quizzes[index]);
                       },
                     ),
                 ],
               ),
             );
          },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showAddQuizDialog(context);
          },
          backgroundColor: const Color(0xFF26E3BA),
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text("Create Quiz", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF3e3e3e),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3e3e3e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.white10,
               borderRadius: BorderRadius.circular(10),
             ),
             child: const Icon(Icons.quiz, color: Colors.white, size: 24),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(quiz.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                 StreamBuilder<int>(
                   stream: _quizService.getQuestionCountStream(quiz.id),
                   builder: (context, snapshot) {
                     final count = snapshot.data ?? 0;
                     return Text("${quiz.subtitle} • $count Qs", style: TextStyle(fontSize: 12, color: Colors.grey[400]));
                   },
                 ),
               ],
             ),
           ),
           ElevatedButton(
             onPressed: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => AdminQuizDetailsScreen(quiz: quiz)),
               );
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFF26E3BA),
               foregroundColor: Colors.black,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             ),
             child: const Text("Manage"),
           ),
           const SizedBox(width: 8),
           IconButton(
             icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
             onPressed: () => _showDeleteConfirmation(quiz.id),
           ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String quizId) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Delete Quiz", style: TextStyle(color: Colors.black)),
        content: const Text("Are you sure? All questions in this quiz will also be deleted.", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
             _quizService.deleteQuiz(quizId);
             Navigator.pop(context);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      )
    );
  }

  void _showAddQuizDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: const Color(0xFFE0E0E0),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create New Quiz",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: "Quiz Title",
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black38)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: "Subtitle (Optional)",
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black38)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        String title = categoryController.text.trim();
                        String subtitle = subtitleController.text.trim();
                        
                        if (title.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title is required"), backgroundColor: Colors.red));
                           return;
                        }

                        Navigator.pop(context);
                        
                        // Proceed to add first question to initialize
                        final newQuestionData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddQuestionScreen(categoryTitle: title),
                          ),
                        );

                        if (newQuestionData != null) {
                           Map<String, dynamic> quizData = {
                              'title': title,
                              'subtitle': subtitle.isNotEmpty ? subtitle : 'General',
                              'iconName': 'article', 
                              'colorHex': 0xFF4169E1, 
                              'questionCount': 0, 
                              'imagePath': 'assets/images/logo.png', 
                           };
                           try {
                             String quizId = await _quizService.addQuiz(quizData);
                             await _quizService.addQuestion(quizId, newQuestionData);
                             if (mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz Created!"), backgroundColor: Colors.green));
                             }
                           } catch (e) {
                             if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                           }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26E3BA), foregroundColor: Colors.black),
                      child: const Text("Next"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                // Pop the dialog
                Navigator.pop(context);
                // Navigate back to login screen and clear all routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}