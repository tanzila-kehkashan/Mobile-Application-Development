import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // For the timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String exerciseName;
  final int expectedCalories;

  const WorkoutSessionScreen({
    super.key,
    required this.exerciseName,
    required this.expectedCalories
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  // Timer variables
  int _secondsCounter = 0;
  Timer? _timer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsCounter++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- SAVE DATA TO FIREBASE ---
  Future<void> _finishWorkout() async {
    _timer?.cancel(); // Stop timer
    setState(() => _isSaving = true);

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Calculate duration in minutes (minimum 1 minute)
        int durationMinutes = (_secondsCounter / 60).ceil();
        if (durationMinutes < 1) durationMinutes = 1;

        // Save to Database
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('workouts')
            .add({
          'exercise': widget.exerciseName,
          'calories': widget.expectedCalories,
          'duration': durationMinutes,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Great Job! Workout Saved."), backgroundColor: Colors.green),
          );
          // Go back to Dashboard
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  // Helper to format time 00:00
  String _getFormattedTime() {
    int minutes = _secondsCounter ~/ 60;
    int seconds = _secondsCounter % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exercise Name
            Text(
              widget.exerciseName,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Burn ${widget.expectedCalories} Kcal",
              style: const TextStyle(color: Colors.cyan, fontSize: 18),
            ),

            const SizedBox(height: 60),

            // Big Timer
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyan, width: 4),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Text(
                _getFormattedTime(),
                style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 80),

            // FINISH BUTTON
            GestureDetector(
              onTap: _isSaving ? null : _finishWorkout,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 60,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/button_gradient_bg.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                alignment: Alignment.center,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "FINISH WORKOUT",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}