import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:momentum/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:momentum/features/profile/presentation/screens/settings_screen.dart';
import 'package:momentum/features/goals/presentation/screens/goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final userName = appState.userName;
    final todayProgress = appState.todayProgress;
    final activityPercent = appState.todayActivityPercent;
    final workouts = appState.workouts;
    final goals = appState.currentGoals;

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white),
            tooltip: 'Daily Goals',
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const GoalsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedListItem(
                    index: 0,
                    child: Text(
                      'Hello, $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedListItem(
                    index: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const GoalsScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          _buildCircularProgress(activityPercent),
                          const SizedBox(width: 30),
                          _buildActivityStats(todayProgress, goals),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedListItem(
                    index: 2,
                    child: const Text(
                      'Recommended Workouts:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedListItem(
                    index: 3,
                    child: _buildWorkoutRecommendations(context, workouts),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double percent) {
    final percentInt = (percent * 100).toInt();
    return CircularPercentIndicator(
      radius: 70.0,
      lineWidth: 10.0,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percentInt%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Today's Activity",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      progressColor: const Color(0xFFE8FF78),
      backgroundColor: const Color(0xFF4A3D7E),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1000,
    );
  }

  Widget _buildActivityStats(dynamic todayProgress, dynamic goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow(
          icon: Icons.local_fire_department,
          label: 'Calories',
          value: todayProgress.caloriesBurnt,
          target: goals?.targetCalories ?? 500,
          unit: 'kcal',
          color: const Color(0xFFFF8A65),
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          icon: Icons.directions_walk,
          label: 'Steps',
          value: todayProgress.steps,
          target: goals?.targetSteps ?? 10000,
          unit: '',
          color: const Color(0xFF64B5F6),
        ),
        const SizedBox(height: 10),
        _buildStatRow(
          icon: Icons.timer,
          label: 'Active',
          value: todayProgress.activeMinutes,
          target: goals?.targetActiveMinutes ?? 60,
          unit: 'min',
          color: const Color(0xFF81C784),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to view goals →',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int value,
    required int target,
    required String unit,
    required Color color,
  }) {
    final percent = (value / target).clamp(0.0, 1.0);
    final isComplete = percent >= 1.0;
    
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: $value${unit.isNotEmpty ? ' $unit' : ''}',
          style: TextStyle(
            color: isComplete ? color : Colors.white,
            fontSize: 14,
            fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isComplete)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(Icons.check_circle, color: color, size: 14),
          ),
      ],
    );
  }

  Widget _buildWorkoutRecommendations(BuildContext context, List workouts) {
    // Take first 2 workouts as recommendations
    final recommendations = workouts.take(2).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card width based on available space
        final cardWidth = (constraints.maxWidth - 20) / 2; // 2 cards with spacing
        final cardHeight = cardWidth * 1.5; // 1.5:1 aspect ratio
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: recommendations.asMap().entries.map((entry) {
            final workout = entry.value;
            return WorkoutCard(
              title: workout.title,
              duration: workout.duration,
              level: workout.level,
              image: workout.image,
              width: cardWidth,
              height: cardHeight,
              onTap: () {
                Navigator.push(
                  context,
                  SlideUpPageRoute(page: WorkoutDetailScreen(workout: workout)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title, duration, level, image;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.duration,
    required this.level,
    required this.image,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF4A3D7E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: SizedBox(
          width: width ?? 150,
          height: height ?? 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF3A2D6E),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      level,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
