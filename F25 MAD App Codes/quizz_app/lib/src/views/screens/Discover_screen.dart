import 'package:flutter/material.dart';
import 'discover_quiz.dart';
import 'discover_category.dart'; // 1. Import the new Category View
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/quiz_model.dart';
import 'package:quizz_app/src/models/user_score_model.dart';
import 'package:quizz_app/src/views/screens/quiz_screen.dart'; // Import QuizScreen

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QuizService _quizService = QuizService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Start at Index 2 ("Categories") as requested
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
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
              _buildSearchBar(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _buildTabsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              "Discover",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6FE0D0),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.white),
          hintText: "Search quizzes...",
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabsContent() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFF6FE0D0), width: 4),
            insets: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, -2.0),
          ),
          indicatorColor: Colors.transparent,
          tabs: const [
            Tab(text: "Top"),
            Tab(text: "Quiz"),
            Tab(text: "Categories"),
            Tab(text: "Friends"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Top Tab
              _buildTopTabContent(),

              // 2. Quiz Tab
              DiscoverQuizView(searchQuery: _searchQuery),

              // 3. Categories Tab (Connected to discover_category.dart)
              DiscoverCategoryView(searchQuery: _searchQuery),

              // 4. Friends Tab
              _buildFriendsTabContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopTabContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Quiz",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text(
                "See all",
                style: TextStyle(
                  color: Color(0xFF6A5ACD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // --- REAL QUIZ STREAM ---
        StreamBuilder<List<Quiz>>(
          stream: _quizService.getQuizzes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No quizzes available yet."));
            }
            
            // Filter quizzes based on search query
            var quizzes = snapshot.data!;
            if (_searchQuery.isNotEmpty) {
              quizzes = quizzes.where((quiz) {
                return quiz.title.toLowerCase().contains(_searchQuery) ||
                       quiz.subtitle.toLowerCase().contains(_searchQuery);
              }).toList();
            }
            
            if (quizzes.isEmpty) {
              return Center(
                child: Text(
                  _searchQuery.isNotEmpty 
                    ? "No quizzes found for '$_searchQuery'"
                    : "No quizzes available yet.",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
            
            final displayQuizzes = quizzes.take(2).toList(); // Show top 2
            return Column(
              children: displayQuizzes.map((quiz) {
                // Safely handle potentially missing colors/icons
                IconData iconData = Icons.article;
                if (quiz.iconName == 'sports_soccer') iconData = Icons.sports_soccer;
                if (quiz.iconName == 'music_note') iconData = Icons.music_note;
                if (quiz.iconName == 'science') iconData = Icons.science;

                 return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                         // Create compatibility map for QuizScreen
                         final quizMap = {
                           'title': quiz.title,
                           'subtitle': quiz.subtitle,
                           'icon': iconData,
                           'iconColor': Color(quiz.colorHex),
                           'bgColor': Color(quiz.colorHex).withOpacity(0.2),
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
                      child: StreamBuilder<int>(
                        stream: _quizService.getQuestionCountStream(quiz.id),
                        builder: (context, countSnapshot) {
                          final count = countSnapshot.data ?? 0;
                          return _buildQuizItem(
                            icon: iconData,
                            title: quiz.title,
                            subtitle: "${quiz.subtitle} • $count Qs",
                            iconColor: Color(quiz.colorHex),
                            iconBackgroundColor: Color(quiz.colorHex).withOpacity(0.1),
                          );
                        }
                      ),
                    ));
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),
        const Text(
          "Friends",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // --- REAL LEADERBOARD STREAM ---
        StreamBuilder<List<UserScore>>(
          stream: _quizService.getLeaderboard(),
          builder: (context, snapshot) {
             if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Center(child: Text("No friends active yet."));
             }
             final players = snapshot.data!.take(3).toList(); // Show top 3
             final List<Color> colors = [Colors.purple.shade100, Colors.orange.shade100, Colors.blue.shade100];

             return Column(
               children: List.generate(players.length, (index) {
                 final player = players[index];
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 12.0),
                   child: _buildFriendItem(
                     name: player.userName,
                     points: "${player.score} points",
                     avatarColor: colors[index % colors.length],
                   ),
                 );
               }),
             );
          },
        ),
      ],
    );
  }

  Widget _buildFriendsTabContent() {
    return StreamBuilder<List<UserScore>>(
      stream: _quizService.getLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friends active yet."));
        }

        final players = snapshot.data!;
        final List<Color> colors = [Colors.purple.shade100, Colors.orange.shade100, Colors.blue.shade100];

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
             return Padding(
               padding: const EdgeInsets.only(bottom: 12.0),
               child: _buildFriendItem(
                 name: player.userName,
                 points: "${player.score} points",
                 avatarColor: colors[index % colors.length],
                 avatarIcon: Icons.person,
               ),
             );
          },
        );
      },
    );
  }

  Widget _buildQuizItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBackgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: iconColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem({
    required String name,
    required String points,
    required Color avatarColor,
    IconData avatarIcon = Icons.person,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: avatarColor,
          child: Icon(
            avatarIcon,
            size: 30,
            color: const Color(0xFF6A5ACD),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                points,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}