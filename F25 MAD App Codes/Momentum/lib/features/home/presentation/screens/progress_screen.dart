import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';
import 'package:momentum/features/profile/presentation/screens/settings_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final progressData = appState.getProgressForPeriod(_selectedPeriod);
    final workoutsThisMonth = appState.workoutsThisMonth;
    final totalActiveTime = appState.totalActiveTimeThisMonth;

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Progress', style: TextStyle(color: Colors.white)),
        actions: [
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedListItem(
                index: 0,
                child: _buildTimeToggle(),
              ),
              const SizedBox(height: 30),
              AnimatedListItem(
                index: 1,
                child: const Text(
                  'Calories Trend',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedListItem(
                index: 2,
                child: _buildChart(progressData),
              ),
              const SizedBox(height: 30),
              AnimatedListItem(
                index: 3,
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedListItem(
                index: 4,
                child: _buildAchievements(workoutsThisMonth, totalActiveTime),
              ),
              const SizedBox(height: 30),
              AnimatedListItem(
                index: 5,
                child: const Text(
                  'Personal Bests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedListItem(
                index: 6,
                child: _buildPersonalBests(appState.personalBests),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Week', 'Month', 'Year'].map((period) {
        final isSelected = _selectedPeriod == period;
        return ElevatedButton(
          onPressed: () {
            setState(() => _selectedPeriod = period);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF4A3D7E) : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: isSelected ? BorderSide.none : const BorderSide(color: Color(0xFF4A3D7E)),
          ),
          child: Text(period, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  Widget _buildChart(List progressData) {
    if (progressData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E).withAlpha(77), // 0.3 * 255 = 77
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No data yet. Complete workouts to see your progress!',
            style: TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final spots = progressData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.caloriesBurnt.toDouble(),
      );
    }).toList();

    final maxY = progressData.map((p) => p.caloriesBurnt).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E).withAlpha(77), // 0.3 * 255 = 77
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.white12, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (progressData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY > 0 ? maxY * 1.2 : 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFE8FF78),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFE8FF78),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFE8FF78).withAlpha(26), // 0.1 * 255 = 26
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(int workouts, Duration activeTime) {
    final hours = activeTime.inHours;
    final minutes = activeTime.inMinutes % 60;
    final timeString = hours > 0 ? '$hours hrs $minutes mins' : '$minutes mins';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Workouts Completed', '$workouts'),
        _buildStatCard('Total Active Time', timeString),
      ],
    );
  }

  Widget _buildPersonalBests(List bests) {
    if (bests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Complete workouts to set personal bests!',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: bests.take(2).map((best) {
        return _buildStatCard(best.title, best.value);
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
