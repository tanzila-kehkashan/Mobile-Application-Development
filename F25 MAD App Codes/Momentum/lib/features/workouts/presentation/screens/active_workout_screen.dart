import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momentum/core/models/models.dart';
import 'package:momentum/core/models/workout_history_model.dart';
import 'package:momentum/core/state/app_state.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;

  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  int _secondsRemaining = 0;
  int _totalElapsedSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;

  ExerciseModel get _currentExercise => widget.workout.exercises[_currentExerciseIndex];
  bool get _isLastExercise => _currentExerciseIndex == widget.workout.exercises.length - 1;

  @override
  void initState() {
    super.initState();
    _startExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    _secondsRemaining = _currentExercise.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
            _totalElapsedSeconds++;
          } else {
            _onExerciseComplete();
          }
        });
      }
    });
  }

  void _onExerciseComplete() {
    if (_isLastExercise) {
      _completeWorkout();
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
      _startExercise();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
      _startExercise();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _skipExercise() {
    // Don't add remaining seconds - only count actual time spent
    if (_isLastExercise) {
      _completeWorkout();
    } else {
      _nextExercise();
    }
  }

  Future<void> _completeWorkout() async {
    _timer?.cancel();

    final appState = AppStateProvider.of(context);
    final durationMinutes = (_totalElapsedSeconds / 60).ceil();
    final caloriesBurned = widget.workout.caloriesPerMinute * durationMinutes;
    
    // Update progress (existing functionality)
    await appState.completeWorkout(widget.workout, durationMinutes);
    
    // Add to workout history (new functionality)
    final historyEntry = WorkoutHistoryEntry.create(
      workoutId: widget.workout.id,
      workoutTitle: widget.workout.title,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    );
    await appState.addWorkoutToHistory(historyEntry);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A3D7E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Workout Complete!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFE8FF78), size: 60),
            const SizedBox(height: 16),
            Text(
              'Great job completing ${widget.workout.title}!',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: $durationMinutes min',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Calories: ~${widget.workout.caloriesPerMinute * durationMinutes} kcal',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to detail
              Navigator.pop(context); // Go back to workouts list
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFFE8FF78), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmQuit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4A3D7E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quit Workout?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your progress will not be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentExerciseIndex + 1) / widget.workout.exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _confirmQuit,
        ),
        title: Text(
          widget.workout.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF4A3D7E),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8FF78)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Exercise name
                  Text(
                    _currentExercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (_currentExercise.description != null)
                    Text(
                      _currentExercise.description!,
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  if (_currentExercise.sets != null && _currentExercise.reps != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_currentExercise.sets} sets × ${_currentExercise.reps} reps',
                        style: const TextStyle(color: Color(0xFFE8FF78), fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 60),
                  // Timer display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8FF78),
                        width: 6,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous
                      IconButton(
                        onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                        icon: Icon(
                          Icons.skip_previous,
                          color: _currentExerciseIndex > 0 ? Colors.white : Colors.white30,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Pause/Play
                      GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8FF78),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                            color: const Color(0xFF201A3F),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Next/Skip
                      IconButton(
                        onPressed: _skipExercise,
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Next exercise preview
          if (!_isLastExercise)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF4A3D7E),
              child: Row(
                children: [
                  const Text(
                    'Next: ',
                    style: TextStyle(color: Colors.white54),
                  ),
                  Text(
                    widget.workout.exercises[_currentExerciseIndex + 1].name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
