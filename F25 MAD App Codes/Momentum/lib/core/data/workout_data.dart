import '../models/models.dart';

/// Workout data for the Momentum fitness app
class WorkoutData {
  /// Get all available workouts
  static List<WorkoutModel> getWorkouts() {
    return [
      WorkoutModel(
        id: 'workout_1',
        title: 'Warm Up',
        duration: '30 min',
        level: 'Basic',
        image: 'assets/images/Workout_1.png',
        caloriesPerMinute: 4,
        exercises: [
          const ExerciseModel(
            id: 'ex_1_1',
            name: 'Jumping Jacks',
            durationSeconds: 60,
            description: 'Full body warm-up exercise',
          ),
          const ExerciseModel(
            id: 'ex_1_2',
            name: 'Arm Circles',
            durationSeconds: 45,
            description: 'Rotate arms in circular motion',
          ),
          const ExerciseModel(
            id: 'ex_1_3',
            name: 'High Knees',
            durationSeconds: 60,
            description: 'Run in place with high knees',
          ),
          const ExerciseModel(
            id: 'ex_1_4',
            name: 'Leg Swings',
            durationSeconds: 45,
            description: 'Swing legs forward and backward',
          ),
          const ExerciseModel(
            id: 'ex_1_5',
            name: 'Hip Circles',
            durationSeconds: 45,
            description: 'Rotate hips in circular motion',
          ),
          const ExerciseModel(
            id: 'ex_1_6',
            name: 'Torso Twists',
            durationSeconds: 45,
            description: 'Twist upper body side to side',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_2',
        title: 'Full Body',
        duration: '45 min',
        level: 'Advanced',
        image: 'assets/images/Workout_2.png',
        caloriesPerMinute: 8,
        exercises: [
          const ExerciseModel(
            id: 'ex_2_1',
            name: 'Burpees',
            durationSeconds: 60,
            sets: 3,
            reps: 10,
            description: 'Full body explosive exercise',
          ),
          const ExerciseModel(
            id: 'ex_2_2',
            name: 'Push-ups',
            durationSeconds: 60,
            sets: 3,
            reps: 15,
            description: 'Chest and arm strengthening',
          ),
          const ExerciseModel(
            id: 'ex_2_3',
            name: 'Squats',
            durationSeconds: 60,
            sets: 3,
            reps: 20,
            description: 'Lower body strength exercise',
          ),
          const ExerciseModel(
            id: 'ex_2_4',
            name: 'Plank',
            durationSeconds: 60,
            description: 'Core stabilization hold',
          ),
          const ExerciseModel(
            id: 'ex_2_5',
            name: 'Lunges',
            durationSeconds: 60,
            sets: 3,
            reps: 12,
            description: 'Leg strengthening exercise',
          ),
          const ExerciseModel(
            id: 'ex_2_6',
            name: 'Mountain Climbers',
            durationSeconds: 60,
            description: 'Cardio and core exercise',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_3',
        title: 'Yoga Flow',
        duration: '60 min',
        level: 'Intermediate',
        image: 'assets/images/Workout_3.png',
        caloriesPerMinute: 3,
        exercises: [
          const ExerciseModel(
            id: 'ex_3_1',
            name: 'Sun Salutation',
            durationSeconds: 180,
            description: 'Traditional yoga flow sequence',
          ),
          const ExerciseModel(
            id: 'ex_3_2',
            name: 'Warrior I',
            durationSeconds: 60,
            description: 'Standing strength pose',
          ),
          const ExerciseModel(
            id: 'ex_3_3',
            name: 'Warrior II',
            durationSeconds: 60,
            description: 'Hip opening warrior pose',
          ),
          const ExerciseModel(
            id: 'ex_3_4',
            name: 'Triangle Pose',
            durationSeconds: 60,
            description: 'Side stretch and balance',
          ),
          const ExerciseModel(
            id: 'ex_3_5',
            name: 'Downward Dog',
            durationSeconds: 90,
            description: 'Full body stretch',
          ),
          const ExerciseModel(
            id: 'ex_3_6',
            name: 'Child\'s Pose',
            durationSeconds: 60,
            description: 'Resting pose',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_4',
        title: 'HIIT Cardio',
        duration: '25 min',
        level: 'Advanced',
        image: 'assets/images/Workout_4.png',
        caloriesPerMinute: 12,
        exercises: [
          const ExerciseModel(
            id: 'ex_4_1',
            name: 'Sprint in Place',
            durationSeconds: 30,
            description: 'Maximum effort sprinting',
          ),
          const ExerciseModel(
            id: 'ex_4_2',
            name: 'Rest',
            durationSeconds: 15,
            description: 'Active recovery',
          ),
          const ExerciseModel(
            id: 'ex_4_3',
            name: 'Jump Squats',
            durationSeconds: 30,
            description: 'Explosive squat jumps',
          ),
          const ExerciseModel(
            id: 'ex_4_4',
            name: 'Rest',
            durationSeconds: 15,
            description: 'Active recovery',
          ),
          const ExerciseModel(
            id: 'ex_4_5',
            name: 'Burpees',
            durationSeconds: 30,
            description: 'Full body cardio',
          ),
          const ExerciseModel(
            id: 'ex_4_6',
            name: 'Rest',
            durationSeconds: 15,
            description: 'Active recovery',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_5',
        title: 'Upper Body',
        duration: '40 min',
        level: 'Intermediate',
        image: 'assets/images/Workout_1.png',
        caloriesPerMinute: 6,
        exercises: [
          const ExerciseModel(
            id: 'ex_5_1',
            name: 'Push-ups',
            durationSeconds: 60,
            sets: 4,
            reps: 12,
            description: 'Chest and triceps',
          ),
          const ExerciseModel(
            id: 'ex_5_2',
            name: 'Diamond Push-ups',
            durationSeconds: 60,
            sets: 3,
            reps: 10,
            description: 'Triceps focused',
          ),
          const ExerciseModel(
            id: 'ex_5_3',
            name: 'Pike Push-ups',
            durationSeconds: 60,
            sets: 3,
            reps: 10,
            description: 'Shoulders focused',
          ),
          const ExerciseModel(
            id: 'ex_5_4',
            name: 'Tricep Dips',
            durationSeconds: 60,
            sets: 3,
            reps: 15,
            description: 'Tricep isolation',
          ),
          const ExerciseModel(
            id: 'ex_5_5',
            name: 'Arm Circles',
            durationSeconds: 45,
            description: 'Shoulder warm-down',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_6',
        title: 'Core Blast',
        duration: '20 min',
        level: 'Basic',
        image: 'assets/images/Workout_2.png',
        caloriesPerMinute: 5,
        exercises: [
          const ExerciseModel(
            id: 'ex_6_1',
            name: 'Crunches',
            durationSeconds: 60,
            sets: 3,
            reps: 20,
            description: 'Upper ab exercise',
          ),
          const ExerciseModel(
            id: 'ex_6_2',
            name: 'Plank',
            durationSeconds: 45,
            description: 'Core stability hold',
          ),
          const ExerciseModel(
            id: 'ex_6_3',
            name: 'Russian Twists',
            durationSeconds: 60,
            sets: 3,
            reps: 20,
            description: 'Oblique exercise',
          ),
          const ExerciseModel(
            id: 'ex_6_4',
            name: 'Leg Raises',
            durationSeconds: 60,
            sets: 3,
            reps: 15,
            description: 'Lower ab exercise',
          ),
          const ExerciseModel(
            id: 'ex_6_5',
            name: 'Side Plank',
            durationSeconds: 45,
            description: 'Oblique stability',
          ),
        ],
      ),
    ];
  }

  /// Get initial progress data for new users
  static List<DailyProgressModel> getInitialProgressData() {
    final now = DateTime.now();
    return [
      DailyProgressModel(
        date: now,
        caloriesBurnt: 0,
        steps: 0,
        activeMinutes: 0,
        workoutsCompleted: 0,
      ),
    ];
  }

  /// Get default personal bests for new users
  static List<PersonalBest> getDefaultPersonalBests() {
    return [];
  }
}
