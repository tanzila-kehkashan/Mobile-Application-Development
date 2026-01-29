import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for persisting data locally using SharedPreferences
/// All user-specific data is now prefixed with userId for isolation
class StorageService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'registered_users';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  final SharedPreferences _prefs;
  String? _currentUserId; // Track current user for data isolation

  StorageService(this._prefs);

  /// Set the current user ID for data isolation
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Get user-specific key for storage
  String _userKey(String baseKey) {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return '${baseKey}_guest';
    }
    return '${baseKey}_$_currentUserId';
  }

  // ==================== User Management ====================

  /// Save the current logged-in user
  Future<bool> saveCurrentUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    return await _prefs.setString(_currentUserKey, json);
  }

  /// Get the current logged-in user
  UserModel? getCurrentUser() {
    final json = _prefs.getString(_currentUserKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  /// Clear the current user (logout)
  Future<bool> clearCurrentUser() async {
    return await _prefs.remove(_currentUserKey);
  }

  /// Register a new user
  Future<bool> registerUser(UserModel user) async {
    final users = getRegisteredUsers();
    
    // Check if email already exists
    if (users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
      return false;
    }
    
    users.add(user);
    final jsonList = users.map((u) => u.toJson()).toList();
    return await _prefs.setString(_usersKey, jsonEncode(jsonList));
  }

  /// Get all registered users
  List<UserModel> getRegisteredUsers() {
    final json = _prefs.getString(_usersKey);
    if (json == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => UserModel.fromJson(j)).toList();
  }

  /// Find a user by email and password
  UserModel? findUser(String email, String password) {
    final users = getRegisteredUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Update a registered user's data
  Future<bool> updateUser(UserModel updatedUser) async {
    final users = getRegisteredUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    
    if (index == -1) {
      // User not in registered list, add them
      users.add(updatedUser);
    } else {
      users[index] = updatedUser;
    }
    
    final jsonList = users.map((u) => u.toJson()).toList();
    
    // Also update current user if it's the same user
    final currentUser = getCurrentUser();
    if (currentUser?.id == updatedUser.id) {
      await saveCurrentUser(updatedUser);
    }
    
    return await _prefs.setString(_usersKey, jsonEncode(jsonList));
  }

  // ==================== Progress Tracking ====================

  /// Save progress data (user-specific)
  Future<bool> saveProgressData(List<DailyProgressModel> progressList) async {
    final key = _userKey('progress_data');
    final jsonList = progressList.map((p) => p.toJson()).toList();
    return await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// Get progress data (user-specific)
  List<DailyProgressModel> getProgressData() {
    final key = _userKey('progress_data');
    final json = _prefs.getString(key);
    if (json == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => DailyProgressModel.fromJson(j)).toList();
  }

  /// Get today's progress
  DailyProgressModel? getTodayProgress() {
    final progressList = getProgressData();
    final today = DateTime.now();
    
    try {
      return progressList.firstWhere((p) => 
        p.date.year == today.year && 
        p.date.month == today.month && 
        p.date.day == today.day
      );
    } catch (_) {
      return null;
    }
  }

  /// Update or create today's progress
  Future<bool> updateTodayProgress(DailyProgressModel progress) async {
    final progressList = getProgressData();
    final today = DateTime.now();
    
    final index = progressList.indexWhere((p) => 
      p.date.year == today.year && 
      p.date.month == today.month && 
      p.date.day == today.day
    );
    
    if (index >= 0) {
      progressList[index] = progress;
    } else {
      progressList.add(progress);
    }
    
    return await saveProgressData(progressList);
  }

  // ==================== Personal Bests ====================

  /// Save personal bests (user-specific)
  Future<bool> savePersonalBests(List<PersonalBest> bests) async {
    final key = _userKey('personal_bests');
    final jsonList = bests.map((b) => b.toJson()).toList();
    return await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// Get personal bests (user-specific)
  List<PersonalBest> getPersonalBests() {
    final key = _userKey('personal_bests');
    final json = _prefs.getString(key);
    if (json == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.map((j) => PersonalBest.fromJson(j)).toList();
  }

  // ==================== Settings ====================

  /// Get notifications enabled setting
  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Set notifications enabled setting
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Get biometric enabled setting
  bool getBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Set biometric enabled setting
  Future<bool> setBiometricEnabled(bool enabled) async {
    return await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  // ==================== Onboarding ====================

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Check if user has seen onboarding
  bool hasSeenOnboarding() {
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Mark onboarding as seen
  Future<bool> setOnboardingSeen() async {
    return await _prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // ==================== Goals ====================

  /// Save daily goals (user-specific)
  Future<bool> saveGoals(Map<String, dynamic> goals) async {
    final key = _userKey('daily_goals');
    return await _prefs.setString(key, jsonEncode(goals));
  }

  /// Get daily goals (user-specific)
  Map<String, dynamic>? getGoals() {
    final key = _userKey('daily_goals');
    final json = _prefs.getString(key);
    if (json == null) return null;
    return jsonDecode(json);
  }

  // ==================== Workout History ====================

  /// Save workout history (user-specific)
  Future<bool> saveWorkoutHistory(List<Map<String, dynamic>> history) async {
    final key = _userKey('workout_history');
    return await _prefs.setString(key, jsonEncode(history));
  }

  /// Get workout history (user-specific)
  List<Map<String, dynamic>> getWorkoutHistory() {
    final key = _userKey('workout_history');
    final json = _prefs.getString(key);
    if (json == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(json);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// Clear workout history (user-specific)
  Future<bool> clearWorkoutHistory() async {
    final key = _userKey('workout_history');
    return await _prefs.remove(key);
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

