import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/models/workout_history_model.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';

/// Screen showing completed workout history
class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final history = appState.workoutHistory;
    final groupedHistory = WorkoutHistoryGroup.groupByDate(history);

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Workout History', style: TextStyle(color: Colors.white)),
        actions: [
          if (history.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: const Color(0xFF4A3D7E),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearConfirmation(context, appState);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      SizedBox(width: 12),
                      Text('Clear History', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedHistory.length,
              itemBuilder: (context, groupIndex) {
                final group = groupedHistory[groupIndex];
                return _buildDateGroup(context, group, groupIndex);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF4A3D7E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history,
              size: 50,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No workout history yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete a workout to see it here',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, WorkoutHistoryGroup group, int groupIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            group.title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...group.entries.asMap().entries.map((entry) {
          final index = entry.key;
          final historyEntry = entry.value;
          return AnimatedListItem(
            index: groupIndex * 5 + index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HistoryEntryCard(entry: historyEntry),
            ),
          );
        }),
      ],
    );
  }

  void _showClearConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF4A3D7E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear History',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all workout history? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await appState.clearWorkoutHistory();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

/// Card widget for a single workout history entry
class HistoryEntryCard extends StatelessWidget {
  final WorkoutHistoryEntry entry;

  const HistoryEntryCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Workout icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8FF78).withAlpha(51),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFFE8FF78),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Workout details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.workoutTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.formattedTime,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatBadge(
                icon: Icons.timer_outlined,
                value: entry.formattedDuration,
              ),
              const SizedBox(height: 6),
              _buildStatBadge(
                icon: Icons.local_fire_department_outlined,
                value: '${entry.caloriesBurned} kcal',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
