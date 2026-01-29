/// Workout history entry model
class WorkoutHistoryEntry {
  final String id;
  final String workoutId;
  final String workoutTitle;
  final DateTime completedAt;
  final int durationMinutes;
  final int caloriesBurned;
  final String? notes;

  const WorkoutHistoryEntry({
    required this.id,
    required this.workoutId,
    required this.workoutTitle,
    required this.completedAt,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes,
  });

  /// Create a new entry with auto-generated ID
  factory WorkoutHistoryEntry.create({
    required String workoutId,
    required String workoutTitle,
    required int durationMinutes,
    required int caloriesBurned,
    String? notes,
  }) {
    return WorkoutHistoryEntry(
      id: 'history_${DateTime.now().millisecondsSinceEpoch}',
      workoutId: workoutId,
      workoutTitle: workoutTitle,
      completedAt: DateTime.now(),
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'workoutTitle': workoutTitle,
    'completedAt': completedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'notes': notes,
  };

  factory WorkoutHistoryEntry.fromJson(Map<String, dynamic> json) => WorkoutHistoryEntry(
    id: json['id'] ?? '',
    workoutId: json['workoutId'] ?? '',
    workoutTitle: json['workoutTitle'] ?? '',
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt']) 
        : DateTime.now(),
    durationMinutes: json['durationMinutes'] ?? 0,
    caloriesBurned: json['caloriesBurned'] ?? 0,
    notes: json['notes'],
  );

  WorkoutHistoryEntry copyWith({
    String? id,
    String? workoutId,
    String? workoutTitle,
    DateTime? completedAt,
    int? durationMinutes,
    int? caloriesBurned,
    String? notes,
  }) {
    return WorkoutHistoryEntry(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
    );
  }

  /// Format duration for display
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) {
      return '$hours hr';
    }
    return '$hours hr $mins min';
  }

  /// Format completed date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
    
    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(completedAt).inDays < 7) {
      return _weekdayName(completedAt.weekday);
    } else {
      return '${completedAt.day}/${completedAt.month}/${completedAt.year}';
    }
  }

  /// Format completed time for display
  String get formattedTime {
    final hour = completedAt.hour;
    final minute = completedAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  @override
  String toString() {
    return 'WorkoutHistoryEntry(id: $id, workout: $workoutTitle, duration: $durationMinutes min)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutHistoryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Group workout history by date
class WorkoutHistoryGroup {
  final String title;
  final List<WorkoutHistoryEntry> entries;

  const WorkoutHistoryGroup({
    required this.title,
    required this.entries,
  });

  /// Group a list of entries by date
  static List<WorkoutHistoryGroup> groupByDate(List<WorkoutHistoryEntry> entries) {
    if (entries.isEmpty) return [];
    
    // Sort by date descending
    final sorted = List<WorkoutHistoryEntry>.from(entries)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    
    final groups = <String, List<WorkoutHistoryEntry>>{};
    
    for (final entry in sorted) {
      final entryDate = DateTime(
        entry.completedAt.year,
        entry.completedAt.month,
        entry.completedAt.day,
      );
      
      String groupKey;
      if (entryDate == today) {
        groupKey = 'Today';
      } else if (entryDate == yesterday) {
        groupKey = 'Yesterday';
      } else if (entryDate.isAfter(thisWeekStart)) {
        groupKey = 'This Week';
      } else if (entryDate.month == now.month && entryDate.year == now.year) {
        groupKey = 'This Month';
      } else {
        groupKey = 'Earlier';
      }
      
      groups.putIfAbsent(groupKey, () => []).add(entry);
    }
    
    // Return in order: Today, Yesterday, This Week, This Month, Earlier
    final orderedKeys = ['Today', 'Yesterday', 'This Week', 'This Month', 'Earlier'];
    return orderedKeys
        .where((key) => groups.containsKey(key))
        .map((key) => WorkoutHistoryGroup(title: key, entries: groups[key]!))
        .toList();
  }
}
