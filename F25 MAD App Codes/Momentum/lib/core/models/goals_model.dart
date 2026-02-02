/// Daily fitness goals model
class DailyGoals {
  final int targetSteps;
  final int targetCalories;
  final int targetActiveMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DailyGoals({
    this.targetSteps = 10000,
    this.targetCalories = 500,
    this.targetActiveMinutes = 60,
    required this.createdAt,
    this.updatedAt,
  });

  /// Default goals for new users
  factory DailyGoals.defaults() {
    return DailyGoals(
      targetSteps: 10000,
      targetCalories: 500,
      targetActiveMinutes: 60,
      createdAt: DateTime.now(),
    );
  }

  /// Light activity preset
  factory DailyGoals.light() {
    return DailyGoals(
      targetSteps: 5000,
      targetCalories: 250,
      targetActiveMinutes: 30,
      createdAt: DateTime.now(),
    );
  }

  /// Moderate activity preset
  factory DailyGoals.moderate() {
    return DailyGoals(
      targetSteps: 10000,
      targetCalories: 500,
      targetActiveMinutes: 60,
      createdAt: DateTime.now(),
    );
  }

  /// Intense activity preset
  factory DailyGoals.intense() {
    return DailyGoals(
      targetSteps: 15000,
      targetCalories: 800,
      targetActiveMinutes: 90,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'targetSteps': targetSteps,
    'targetCalories': targetCalories,
    'targetActiveMinutes': targetActiveMinutes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory DailyGoals.fromJson(Map<String, dynamic> json) => DailyGoals(
    targetSteps: json['targetSteps'] ?? 10000,
    targetCalories: json['targetCalories'] ?? 500,
    targetActiveMinutes: json['targetActiveMinutes'] ?? 60,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : null,
  );

  DailyGoals copyWith({
    int? targetSteps,
    int? targetCalories,
    int? targetActiveMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyGoals(
      targetSteps: targetSteps ?? this.targetSteps,
      targetCalories: targetCalories ?? this.targetCalories,
      targetActiveMinutes: targetActiveMinutes ?? this.targetActiveMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Calculate step progress percentage (0.0 to 1.0)
  double stepProgress(int currentSteps) {
    return (currentSteps / targetSteps).clamp(0.0, 1.0);
  }

  /// Calculate calorie progress percentage (0.0 to 1.0)
  double calorieProgress(int currentCalories) {
    return (currentCalories / targetCalories).clamp(0.0, 1.0);
  }

  /// Calculate active minutes progress percentage (0.0 to 1.0)
  double activeMinutesProgress(int currentMinutes) {
    return (currentMinutes / targetActiveMinutes).clamp(0.0, 1.0);
  }

  /// Calculate overall progress (average of all goals)
  double overallProgress(int steps, int calories, int minutes) {
    return (stepProgress(steps) + calorieProgress(calories) + activeMinutesProgress(minutes)) / 3;
  }

  @override
  String toString() {
    return 'DailyGoals(steps: $targetSteps, calories: $targetCalories, minutes: $targetActiveMinutes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyGoals &&
        other.targetSteps == targetSteps &&
        other.targetCalories == targetCalories &&
        other.targetActiveMinutes == targetActiveMinutes;
  }

  @override
  int get hashCode {
    return targetSteps.hashCode ^ targetCalories.hashCode ^ targetActiveMinutes.hashCode;
  }
}

/// Goal presets for quick selection
enum GoalPreset {
  light('Light', 'Perfect for beginners or rest days'),
  moderate('Moderate', 'Balanced daily activity'),
  intense('Intense', 'For active fitness enthusiasts'),
  custom('Custom', 'Set your own goals');

  final String name;
  final String description;
  
  const GoalPreset(this.name, this.description);

  DailyGoals toGoals() {
    switch (this) {
      case GoalPreset.light:
        return DailyGoals.light();
      case GoalPreset.moderate:
        return DailyGoals.moderate();
      case GoalPreset.intense:
        return DailyGoals.intense();
      case GoalPreset.custom:
        return DailyGoals.defaults();
    }
  }
}
