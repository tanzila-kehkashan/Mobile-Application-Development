import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/models/models.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';
import 'package:momentum/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:momentum/features/workouts/presentation/screens/workout_history_screen.dart';
import 'package:momentum/features/workouts/presentation/screens/create_workout_screen.dart';
import 'package:momentum/features/profile/presentation/screens/settings_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final allWorkouts = appState.workouts;
    final filteredWorkouts = _searchQuery.isEmpty
        ? allWorkouts
        : appState.searchWorkouts(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Workout', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Workout History',
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const WorkoutHistoryScreen()),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            SlideUpPageRoute(page: const CreateWorkoutScreen()),
          );
        },
        backgroundColor: const Color(0xFFE8FF78),
        icon: const Icon(Icons.add, color: Color(0xFF201A3F)),
        label: const Text(
          'Create Workout',
          style: TextStyle(
            color: Color(0xFF201A3F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            AnimatedFadeIn(
              delay: const Duration(milliseconds: 100),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredWorkouts.isEmpty
                  ? const Center(
                      child: Text(
                        'No workouts found',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredWorkouts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final workout = filteredWorkouts[index];
                        return AnimatedListItem(
                          index: index,
                          delay: const Duration(milliseconds: 80),
                          child: WorkoutCard(
                            workout: workout,
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideUpPageRoute(page: WorkoutDetailScreen(workout: workout)),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search all Workouts',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF4A3D7E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Image.asset(
              workout.image,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: const Color(0xFF4A3D7E),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(179), // 0.7 * 255 = 179
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${workout.duration} • ${workout.level}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FF78),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${workout.exercises.length} exercises',
                      style: const TextStyle(
                        color: Color(0xFF201A3F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
