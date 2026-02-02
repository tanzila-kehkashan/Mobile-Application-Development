import 'package:flutter/material.dart';
import 'package:quizz_app/services/quiz_service.dart';
import 'package:quizz_app/src/models/user_score_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const String _backgroundImagePath = 'assets/images/background.png';
  final QuizService _quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // 1. The Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_backgroundImagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 2. The Scaffold for UI elements
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
            title: const Text(
              'Leaderboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),
          body: StreamBuilder<List<UserScore>>(
            stream: _quizService.getLeaderboard(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
              }
              
              final scores = snapshot.data ?? [];
              
              if (scores.isEmpty) {
                 return const Center(child: Text("No scores yet!", style: TextStyle(color: Colors.white, fontSize: 18)));
              }

              // Top 3 Players Logic
              UserScore? firstPlace = scores.isNotEmpty ? scores[0] : null;
              UserScore? secondPlace = scores.length > 1 ? scores[1] : null;
              UserScore? thirdPlace = scores.length > 2 ? scores[2] : null;
              
              // Remaining List (sublist from index 3)
              List<UserScore> remainingScores = scores.length > 3 ? scores.sublist(3) : [];

              return Column(
                children: [
                  // --- Top 3 Players Section ---
                  Container(
                    height: screenHeight * 0.35,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 2nd Place (Left)
                         if (secondPlace != null)
                          _buildTopPlayer(
                            name: secondPlace.userName,
                            score: '${secondPlace.score}',
                            radius: 40,
                            icon: Icons.person, // Or vary based on data
                            color: Colors.pink[200]!,
                            rankLabel: "2",
                          )
                        else
                          const SizedBox(width: 80), // Placeholder space

                        // 1st Place (Center)
                        if (firstPlace != null)
                          _buildTopPlayer(
                            name: firstPlace.userName,
                            score: '${firstPlace.score}',
                            radius: 55,
                            icon: Icons.emoji_events,
                            color: Colors.amber[300]!,
                             rankLabel: "1",
                          ),

                        // 3rd Place (Right)
                        if (thirdPlace != null)
                          _buildTopPlayer(
                            name: thirdPlace.userName,
                            score: '${thirdPlace.score}',
                            radius: 40,
                            icon: Icons.person,
                            color: Colors.blue[200]!,
                             rankLabel: "3",
                          )
                         else
                          const SizedBox(width: 80), // Placeholder
                      ],
                    ),
                  ),

                  // --- Rest of the List Section ---
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        child: remainingScores.isEmpty 
                        ? const Center(child: Text("Join the race! Play a quiz."))
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 16.0),
                          itemCount: remainingScores.length,
                          itemBuilder: (context, index) {
                            final userScore = remainingScores[index];
                            final rank = index + 4; // Because first 3 are handled above
                            
                            // Cycle colors
                            final colors = [
                              Colors.grey[400],
                              Colors.blue[300],
                              Colors.orange[300],
                              Colors.yellow[700],
                              Colors.brown[300]
                            ];
                            final color = colors[index % colors.length]!;

                            return _buildRankItem(
                              rank: '$rank',
                              name: userScore.userName,
                              score: '${userScore.score}/${userScore.totalQuestions}', // e.g. 8/10
                              icon: Icons.person,
                              color: color,
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.black12,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayer({
    required String name,
    required String score,
    required double radius,
    required IconData icon,
    required Color color,
    required String rankLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: color,
              child: Icon(icon, size: radius * 0.6, color: Colors.white),
            ),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Text(rankLabel, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12))
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name.length > 8 ? '${name.substring(0, 7)}...' : name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          score, // Just the score number
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem({
    required String rank,
    required String name,
    required String score,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 30, // Fixed width for alignment
            child: Text(
              rank,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded( // Prevent overflow
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}