import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/models/goals_model.dart';
import 'package:momentum/core/widgets/loading_button.dart';
import 'package:momentum/core/utils/error_handler.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Screen for viewing and editing daily fitness goals
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final goals = appState.currentGoals ?? DailyGoals.defaults();
    final todayProgress = appState.todayProgress;
    
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daily Goals', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall progress
            _buildOverallProgress(goals, todayProgress),
            
            const SizedBox(height: 32),
            
            // Individual goals
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildGoalCard(
              icon: Icons.local_fire_department,
              title: 'Calories',
              current: todayProgress.caloriesBurnt,
              target: goals.targetCalories,
              unit: 'kcal',
              color: const Color(0xFFFF8A65),
            ),
            const SizedBox(height: 12),
            
            _buildGoalCard(
              icon: Icons.directions_walk,
              title: 'Steps',
              current: todayProgress.steps,
              target: goals.targetSteps,
              unit: 'steps',
              color: const Color(0xFF64B5F6),
            ),
            const SizedBox(height: 12),
            
            _buildGoalCard(
              icon: Icons.timer,
              title: 'Active Minutes',
              current: todayProgress.activeMinutes,
              target: goals.targetActiveMinutes,
              unit: 'min',
              color: const Color(0xFF81C784),
            ),
            
            const SizedBox(height: 32),
            
            // Quick presets
            const Text(
              'Quick Presets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildPresetButton(GoalPreset.light)),
                const SizedBox(width: 12),
                Expanded(child: _buildPresetButton(GoalPreset.moderate)),
                const SizedBox(width: 12),
                Expanded(child: _buildPresetButton(GoalPreset.intense)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Edit custom goals button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showEditGoalsDialog(context, goals),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Set Custom Goals',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(DailyGoals goals, dynamic todayProgress) {
    final overallPercent = goals.overallProgress(
      todayProgress.steps,
      todayProgress.caloriesBurnt,
      todayProgress.activeMinutes,
    );
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A3D7E),
            const Color(0xFF6B5B95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: overallPercent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(overallPercent * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Complete',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            progressColor: const Color(0xFFE8FF78),
            backgroundColor: Colors.white24,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 16),
          Text(
            overallPercent >= 1.0
                ? '🎉 All goals completed!'
                : 'Keep going, you\'re doing great!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
  }) {
    final percent = (current / target).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$current / $target $unit',
                      style: TextStyle(
                        color: percent >= 1.0 ? color : Colors.white70,
                        fontSize: 14,
                        fontWeight: percent >= 1.0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: percent,
                  progressColor: color,
                  backgroundColor: Colors.white24,
                  barRadius: const Radius.circular(4),
                  animation: true,
                ),
              ],
            ),
          ),
          if (percent >= 1.0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.check_circle, color: color, size: 28),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(GoalPreset preset) {
    return GestureDetector(
      onTap: () => _applyPreset(preset),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(
              preset == GoalPreset.light
                  ? Icons.directions_walk
                  : preset == GoalPreset.moderate
                      ? Icons.directions_run
                      : Icons.sports_martial_arts,
              color: const Color(0xFFE8FF78),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              preset == GoalPreset.light
                  ? '5k steps'
                  : preset == GoalPreset.moderate
                      ? '10k steps'
                      : '15k steps',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(GoalPreset preset) async {
    final appState = AppStateProvider.of(context);
    final goals = preset.toGoals();
    await appState.updateGoals(goals);
    if (mounted) {
      ErrorHandler.showSuccess(context, '${preset.name} goals applied!');
      setState(() {});
    }
  }

  void _showEditGoalsDialog(BuildContext context, DailyGoals currentGoals) {
    final appState = AppStateProvider.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => EditGoalsBottomSheet(
        currentGoals: currentGoals,
        onSave: (goals) async {
          await appState.updateGoals(goals);
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Goals updated!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          }
        },
      ),
    );
  }
}

/// Bottom sheet for editing custom goals
class EditGoalsBottomSheet extends StatefulWidget {
  final DailyGoals currentGoals;
  final Function(DailyGoals) onSave;

  const EditGoalsBottomSheet({
    super.key,
    required this.currentGoals,
    required this.onSave,
  });

  @override
  State<EditGoalsBottomSheet> createState() => _EditGoalsBottomSheetState();
}

class _EditGoalsBottomSheetState extends State<EditGoalsBottomSheet> {
  late int _targetSteps;
  late int _targetCalories;
  late int _targetMinutes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetSteps = widget.currentGoals.targetSteps;
    _targetCalories = widget.currentGoals.targetCalories;
    _targetMinutes = widget.currentGoals.targetActiveMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF4A3D7E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Set Custom Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSlider(
              label: 'Daily Steps',
              value: _targetSteps,
              min: 1000,
              max: 30000,
              divisions: 29,
              unit: 'steps',
              onChanged: (val) => setState(() => _targetSteps = val.toInt()),
            ),
            const SizedBox(height: 20),
            
            _buildSlider(
              label: 'Calories to Burn',
              value: _targetCalories,
              min: 100,
              max: 2000,
              divisions: 19,
              unit: 'kcal',
              onChanged: (val) => setState(() => _targetCalories = val.toInt()),
            ),
            const SizedBox(height: 20),
            
            _buildSlider(
              label: 'Active Minutes',
              value: _targetMinutes,
              min: 15,
              max: 180,
              divisions: 11,
              unit: 'min',
              onChanged: (val) => setState(() => _targetMinutes = val.toInt()),
            ),
            const SizedBox(height: 32),
            
            LoadingButton(
              text: 'Save Goals',
              isLoading: _isSaving,
              onPressed: _saveGoals,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value $unit',
              style: const TextStyle(
                color: Color(0xFFE8FF78),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE8FF78),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFFE8FF78),
            overlayColor: const Color(0xFFE8FF78).withAlpha(51),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _saveGoals() async {
    setState(() => _isSaving = true);
    
    final newGoals = widget.currentGoals.copyWith(
      targetSteps: _targetSteps,
      targetCalories: _targetCalories,
      targetActiveMinutes: _targetMinutes,
    );
    
    await widget.onSave(newGoals);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
