// Data models for the Momentum fitness app

class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  String name;
  double? weight; // in lbs
  double? height; // in inches
  int? age;
  DateTime? dateOfBirth;
  bool useMetricUnits;
  String? profileImagePath;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.name = '',
    this.weight,
    this.height,
    this.age,
    this.dateOfBirth,
    this.useMetricUnits = false,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'password': password,
    'name': name,
    'weight': weight,
    'height': height,
    'age': age,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'useMetricUnits': useMetricUnits,
    'profileImagePath': profileImagePath,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    name: json['name'] ?? '',
    weight: json['weight']?.toDouble(),
    height: json['height']?.toDouble(),
    age: json['age'],
    dateOfBirth: json['dateOfBirth'] != null 
        ? DateTime.parse(json['dateOfBirth']) 
        : null,
    useMetricUnits: json['useMetricUnits'] ?? false,
    profileImagePath: json['profileImagePath'],
  );

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? name,
    double? weight,
    double? height,
    int? age,
    DateTime? dateOfBirth,
    bool? useMetricUnits,
    String? profileImagePath,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final int durationSeconds;
  final int? sets;
  final int? reps;
  final String? description;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.durationSeconds,
    this.sets,
    this.reps,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'durationSeconds': durationSeconds,
    'sets': sets,
    'reps': reps,
    'description': description,
  };

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    durationSeconds: json['durationSeconds'] ?? 0,
    sets: json['sets'],
    reps: json['reps'],
    description: json['description'],
  );
}

class WorkoutModel {
  final String id;
  final String title;
  final String duration;
  final String level;
  final String image;
  final List<ExerciseModel> exercises;
  final int caloriesPerMinute;

  const WorkoutModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.image,
    required this.exercises,
    this.caloriesPerMinute = 5,
  });

  int get totalDurationMinutes {
    int totalSeconds = 0;
    for (var exercise in exercises) {
      totalSeconds += exercise.durationSeconds;
    }
    return (totalSeconds / 60).ceil();
  }

  int get estimatedCalories => totalDurationMinutes * caloriesPerMinute;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'duration': duration,
    'level': level,
    'image': image,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'caloriesPerMinute': caloriesPerMinute,
  };

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    duration: json['duration'] ?? '',
    level: json['level'] ?? '',
    image: json['image'] ?? '',
    exercises: (json['exercises'] as List<dynamic>?)
        ?.map((e) => ExerciseModel.fromJson(e))
        .toList() ?? [],
    caloriesPerMinute: json['caloriesPerMinute'] ?? 5,
  );
}

class DailyProgressModel {
  final DateTime date;
  final int caloriesBurnt;
  final int steps;
  final int activeMinutes;
  final int workoutsCompleted;
  final List<String> completedWorkoutIds;

  const DailyProgressModel({
    required this.date,
    this.caloriesBurnt = 0,
    this.steps = 0,
    this.activeMinutes = 0,
    this.workoutsCompleted = 0,
    this.completedWorkoutIds = const [],
  });

  DailyProgressModel copyWith({
    DateTime? date,
    int? caloriesBurnt,
    int? steps,
    int? activeMinutes,
    int? workoutsCompleted,
    List<String>? completedWorkoutIds,
  }) {
    return DailyProgressModel(
      date: date ?? this.date,
      caloriesBurnt: caloriesBurnt ?? this.caloriesBurnt,
      steps: steps ?? this.steps,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      completedWorkoutIds: completedWorkoutIds ?? this.completedWorkoutIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'caloriesBurnt': caloriesBurnt,
    'steps': steps,
    'activeMinutes': activeMinutes,
    'workoutsCompleted': workoutsCompleted,
    'completedWorkoutIds': completedWorkoutIds,
  };

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) => DailyProgressModel(
    date: DateTime.parse(json['date']),
    caloriesBurnt: json['caloriesBurnt'] ?? 0,
    steps: json['steps'] ?? 0,
    activeMinutes: json['activeMinutes'] ?? 0,
    workoutsCompleted: json['workoutsCompleted'] ?? 0,
    completedWorkoutIds: List<String>.from(json['completedWorkoutIds'] ?? []),
  );
}

class AchievementModel {
  final String id;
  final String title;
  final String value;
  final DateTime? achievedDate;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.value,
    this.achievedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'achievedDate': achievedDate?.toIso8601String(),
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    value: json['value'] ?? '',
    achievedDate: json['achievedDate'] != null 
        ? DateTime.parse(json['achievedDate']) 
        : null,
  );
}

class PersonalBest {
  final String id;
  final String title;
  final String value;
  final DateTime achievedDate;

  const PersonalBest({
    required this.id,
    required this.title,
    required this.value,
    required this.achievedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'achievedDate': achievedDate.toIso8601String(),
  };

  factory PersonalBest.fromJson(Map<String, dynamic> json) => PersonalBest(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    value: json['value'] ?? '',
    achievedDate: DateTime.parse(json['achievedDate']),
  );
}
