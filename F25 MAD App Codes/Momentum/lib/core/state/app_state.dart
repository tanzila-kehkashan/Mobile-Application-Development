import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/goals_model.dart';
import '../models/workout_history_model.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../data/workout_data.dart';

/// Application state management using InheritedWidget pattern
class AppState extends ChangeNotifier {
  final StorageService _storage;
  final AuthService _authService;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _localUserData;
  List<WorkoutModel> _workouts = [];
  List<DailyProgressModel> _progressHistory = [];
  List<PersonalBest> _personalBests = [];
  List<WorkoutHistoryEntry> _workoutHistory = [];
  DailyGoals? _currentGoals;
  bool _notificationsEnabled = true;
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;
  bool _isLoading = false;
  String? _loadingMessage;

  AppState(this._storage, this._authService);

  // ==================== Getters ====================

  AuthService get authService => _authService;
  
  /// Get Firebase user
  User? get firebaseUser => _authService.currentUser;
  
  /// Check if logged in via Firebase
  bool get isLoggedIn => _authService.isLoggedIn;
  
  /// Get user display name
  String get userName => firebaseUser?.displayName ?? _localUserData?.name ?? 'User';
  
  /// Get user email
  String get userEmail => firebaseUser?.email ?? _localUserData?.email ?? '';

  /// Get local user data for additional profile info
  UserModel? get localUserData => _localUserData;
  
  List<WorkoutModel> get workouts => _workouts;
  List<DailyProgressModel> get progressHistory => _progressHistory;
  List<PersonalBest> get personalBests => _personalBests;
  List<WorkoutHistoryEntry> get workoutHistory => _workoutHistory;
  DailyGoals? get currentGoals => _currentGoals;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isInitialized => _isInitialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  DailyProgressModel get todayProgress {
    final today = DateTime.now();
    try {
      return _progressHistory.firstWhere((p) =>
          p.date.year == today.year &&
          p.date.month == today.month &&
          p.date.day == today.day);
    } catch (_) {
      return DailyProgressModel(date: today);
    }
  }

  /// Calculate activity percentage for today (based on user's goal or default 60 min)
  double get todayActivityPercent {
    final goalMinutes = _currentGoals?.targetActiveMinutes ?? 60;
    return (todayProgress.activeMinutes / goalMinutes).clamp(0.0, 1.0);
  }

  // ==================== Initialization ====================

  /// Initialize app state from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load onboarding status
    _hasSeenOnboarding = _storage.hasSeenOnboarding();

    // Load local user data from storage
    _localUserData = _storage.getCurrentUser();
    
    // Set current user ID for data isolation
    _storage.setCurrentUserId(_localUserData?.id ?? firebaseUser?.uid);

    // Load workout library
    _workouts = WorkoutData.getWorkouts();

    // Load user-specific progress history
    _progressHistory = _storage.getProgressData();
    if (_progressHistory.isEmpty) {
      // Initialize empty progress for new user
      _progressHistory = WorkoutData.getInitialProgressData();
      await _storage.saveProgressData(_progressHistory);
    }

    // Load personal bests
    _personalBests = _storage.getPersonalBests();
    if (_personalBests.isEmpty) {
      _personalBests = WorkoutData.getDefaultPersonalBests();
      await _storage.savePersonalBests(_personalBests);
    }

    // Load goals
    final goalsJson = _storage.getGoals();
    if (goalsJson != null) {
      _currentGoals = DailyGoals.fromJson(goalsJson);
    } else {
      _currentGoals = DailyGoals.defaults();
    }

    // Load workout history
    final historyJson = _storage.getWorkoutHistory();
    _workoutHistory = historyJson.map((e) => WorkoutHistoryEntry.fromJson(e)).toList();

    // Load settings
    _notificationsEnabled = _storage.getNotificationsEnabled();

    _isInitialized = true;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading, [String? message]) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  /// Mark onboarding as seen
  Future<void> setOnboardingSeen() async {
    _hasSeenOnboarding = true;
    await _storage.setOnboardingSeen();
    notifyListeners();
  }

  // ==================== Auth Methods ====================

  /// Register with Firebase
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await _authService.register(
      email: email,
      password: password,
      displayName: username,
    );

    if (result.success && result.user != null) {
      // Set current user ID for data isolation BEFORE saving data
      _storage.setCurrentUserId(result.user!.uid);
      
      // Save local user data for additional profile info
      _localUserData = UserModel(
        id: result.user!.uid,
        username: username,
        email: email,
        password: '', // Don't store password locally
        name: username,
      );
      await _storage.saveCurrentUser(_localUserData!);
      await _storage.registerUser(_localUserData!);
      
      // Initialize fresh data for new user
      _progressHistory = WorkoutData.getInitialProgressData();
      await _storage.saveProgressData(_progressHistory);
      _personalBests = WorkoutData.getDefaultPersonalBests();
      await _storage.savePersonalBests(_personalBests);
      _currentGoals = DailyGoals.defaults();
      await _storage.saveGoals(_currentGoals!.toJson());
      _workoutHistory = [];
      
      // Sync initial user data to Firestore
      await _firestoreService.syncUserData(_localUserData!);
      
      notifyListeners();
    }

    return result;
  }

  /// Login with Firebase
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      // Set current user ID for data isolation BEFORE loading data
      _storage.setCurrentUserId(result.user!.uid);
      
      // Load or create local user data
      _localUserData = _storage.getCurrentUser();
      if (_localUserData == null || _localUserData!.id != result.user!.uid) {
        _localUserData = UserModel(
          id: result.user!.uid,
          username: result.user!.displayName ?? '',
          email: result.user!.email ?? email,
          password: '',
          name: result.user!.displayName ?? '',
        );
        await _storage.saveCurrentUser(_localUserData!);
      }
      
      // Reload all user-specific data
      await _reloadUserData();
      
      // Fetch data from Firestore and merge with local
      await _syncDataFromCloud();
      
      notifyListeners();
    }

    return result;
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _localUserData = null;
    await _storage.clearCurrentUser();
    
    // Clear user ID - switch to guest mode
    _storage.setCurrentUserId(null);
    
    // Reload data for guest mode
    await _reloadUserData();
    
    notifyListeners();
  }

  /// Reload user-specific data from storage
  Future<void> _reloadUserData() async {
    _progressHistory = _storage.getProgressData();
    if (_progressHistory.isEmpty) {
      _progressHistory = WorkoutData.getInitialProgressData();
      await _storage.saveProgressData(_progressHistory);
    }

    _personalBests = _storage.getPersonalBests();
    if (_personalBests.isEmpty) {
      _personalBests = WorkoutData.getDefaultPersonalBests();
      await _storage.savePersonalBests(_personalBests);
    }

    final goalsJson = _storage.getGoals();
    if (goalsJson != null) {
      _currentGoals = DailyGoals.fromJson(goalsJson);
    } else {
      _currentGoals = DailyGoals.defaults();
    }

    final historyJson = _storage.getWorkoutHistory();
    _workoutHistory = historyJson.map((e) => WorkoutHistoryEntry.fromJson(e)).toList();
  }

  // ==================== Profile Methods ====================

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    double? weight,
    double? height,
    int? age,
    DateTime? dateOfBirth,
    bool? useMetricUnits,
  }) async {
    // Update Firebase display name if changed
    if (name != null && name != firebaseUser?.displayName) {
      await _authService.updateProfile(displayName: name);
    }

    // Create local user data if it doesn't exist (e.g., guest user)
    if (_localUserData == null) {
      final userId = firebaseUser?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      _localUserData = UserModel(
        id: userId,
        username: name ?? firebaseUser?.displayName ?? 'Guest',
        email: email ?? firebaseUser?.email ?? '',
        password: '',
        name: name ?? firebaseUser?.displayName ?? '',
      );
    }

    // Update local data
    _localUserData = _localUserData!.copyWith(
      name: name,
      email: email,
      weight: weight,
      height: height,
      age: age,
      dateOfBirth: dateOfBirth,
      useMetricUnits: useMetricUnits,
    );

    // Save current user first (this always works)
    await _storage.saveCurrentUser(_localUserData!);
    
    // Then update in registered users list
    final success = await _storage.updateUser(_localUserData!);
    
    if (success) {
      // Sync profile changes to cloud
      if (_authService.isLoggedIn) {
        await _firestoreService.syncUserData(_localUserData!);
      }
      notifyListeners();
    }
    return success;
  }

  // ==================== Workout Methods ====================

  /// Get workout by ID
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search workouts by title
  List<WorkoutModel> searchWorkouts(String query) {
    if (query.isEmpty) return _workouts;
    return _workouts
        .where((w) => w.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Add a custom workout
  Future<void> addCustomWorkout(WorkoutModel workout) async {
    _workouts.add(workout);
    notifyListeners();
  }

  /// Remove a custom workout
  Future<void> removeCustomWorkout(String workoutId) async {
    _workouts.removeWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  /// Complete a workout and update progress
  Future<void> completeWorkout(WorkoutModel workout, int durationMinutes) async {
    final today = DateTime.now();
    
    // Get or create today's progress
    DailyProgressModel progress = todayProgress;
    
    // Update progress
    progress = progress.copyWith(
      date: today,
      caloriesBurnt: progress.caloriesBurnt + (workout.caloriesPerMinute * durationMinutes),
      activeMinutes: progress.activeMinutes + durationMinutes,
      workoutsCompleted: progress.workoutsCompleted + 1,
      completedWorkoutIds: [...progress.completedWorkoutIds, workout.id],
    );

    // Update in list
    final index = _progressHistory.indexWhere((p) =>
        p.date.year == today.year &&
        p.date.month == today.month &&
        p.date.day == today.day);

    if (index >= 0) {
      _progressHistory[index] = progress;
    } else {
      _progressHistory.add(progress);
    }

    // Save to storage
    await _storage.saveProgressData(_progressHistory);
    
    // Sync today's progress to cloud
    if (_authService.isLoggedIn) {
      await _firestoreService.syncDayProgress(progress);
    }
    
    notifyListeners();
  }

  // ==================== Settings Methods ====================

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storage.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  // ==================== Progress Calculation ====================

  /// Get progress data for a specific time period
  List<DailyProgressModel> getProgressForPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return _progressHistory
        .where((p) => p.date.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Calculate total workouts this month
  int get workoutsThisMonth {
    final now = DateTime.now();
    return _progressHistory
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0, (sum, p) => sum + p.workoutsCompleted);
  }

  /// Calculate total active time this month
  Duration get totalActiveTimeThisMonth {
    final now = DateTime.now();
    final totalMinutes = _progressHistory
        .where((p) => p.date.year == now.year && p.date.month == now.month)
        .fold(0, (sum, p) => sum + p.activeMinutes);
    return Duration(minutes: totalMinutes);
  }

  // ==================== Goals Methods ====================

  /// Update daily goals
  Future<void> updateGoals(DailyGoals goals) async {
    _currentGoals = goals;
    await _storage.saveGoals(goals.toJson());
    
    // Sync to cloud if authenticated
    if (_authService.isLoggedIn) {
      await _firestoreService.syncGoals(goals);
    }
    
    notifyListeners();
  }

  // ==================== Workout History Methods ====================

  /// Add workout to history
  Future<void> addWorkoutToHistory(WorkoutHistoryEntry entry) async {
    _workoutHistory.insert(0, entry);
    await _storage.saveWorkoutHistory(
      _workoutHistory.map((e) => e.toJson()).toList(),
    );
    
    // Sync to cloud if authenticated
    if (_authService.isLoggedIn) {
      await _firestoreService.addWorkoutToHistory(entry);
    }
    
    notifyListeners();
  }

  /// Clear workout history
  Future<void> clearWorkoutHistory() async {
    _workoutHistory.clear();
    await _storage.clearWorkoutHistory();
    
    // Sync to cloud if authenticated
    if (_authService.isLoggedIn) {
      await _firestoreService.clearWorkoutHistory();
    }
    
    notifyListeners();
  }

  // ==================== Profile Picture Methods ====================

  /// Update profile picture path
  Future<bool> updateProfilePicture(String? imagePath) async {
    // Create local user data if it doesn't exist
    if (_localUserData == null) {
      final userId = firebaseUser?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      _localUserData = UserModel(
        id: userId,
        username: firebaseUser?.displayName ?? 'Guest',
        email: firebaseUser?.email ?? '',
        password: '',
        name: firebaseUser?.displayName ?? '',
      );
    }
    
    _localUserData = _localUserData!.copyWith(profileImagePath: imagePath);
    
    // Save current user first
    await _storage.saveCurrentUser(_localUserData!);
    
    // Then update in registered users list
    final success = await _storage.updateUser(_localUserData!);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // ==================== Cloud Sync Methods ====================

  /// Private helper to sync data from cloud on login
  Future<void> _syncDataFromCloud() async {
    if (!_authService.isLoggedIn) return;
    
    try {
      final results = await _firestoreService.fullSync();
      
      if (results['success'] == true) {
        // Update user data from cloud if available
        if (results['userData'] != null) {
          _localUserData = results['userData'] as UserModel;
          await _storage.saveCurrentUser(_localUserData!);
        }
        
        // Update progress from cloud
        if (results['progress'] != null) {
          final cloudProgress = results['progress'] as List<DailyProgressModel>;
          if (cloudProgress.isNotEmpty) {
            _progressHistory = cloudProgress;
            await _storage.saveProgressData(_progressHistory);
          }
        }
        
        // Update goals from cloud
        if (results['goals'] != null) {
          _currentGoals = results['goals'] as DailyGoals;
          await _storage.saveGoals(_currentGoals!.toJson());
        }
        
        // Update workout history from cloud
        if (results['workoutHistory'] != null) {
          final cloudHistory = results['workoutHistory'] as List<WorkoutHistoryEntry>;
          if (cloudHistory.isNotEmpty) {
            _workoutHistory = cloudHistory;
            await _storage.saveWorkoutHistory(
              _workoutHistory.map((e) => e.toJson()).toList(),
            );
          }
        }
      } else {
        // If cloud sync fails, sync local data up
        await syncToCloud();
      }
    } catch (e) {
      // On error, try to sync local data up
      debugPrint('Error syncing from cloud: $e');
    }
  }

  /// Sync all data to cloud
  Future<bool> syncToCloud() async {
    if (!_authService.isLoggedIn) return false;
    
    try {
      setLoading(true, 'Syncing data...');
      
      // Sync user data
      if (_localUserData != null) {
        await _firestoreService.syncUserData(_localUserData!);
      }
      
      // Sync progress
      await _firestoreService.syncProgress(_progressHistory);
      
      // Sync goals
      if (_currentGoals != null) {
        await _firestoreService.syncGoals(_currentGoals!);
      }
      
      // Sync workout history
      await _firestoreService.syncWorkoutHistory(_workoutHistory);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  /// Fetch all data from cloud
  Future<bool> syncFromCloud() async {
    if (!_authService.isLoggedIn) return false;
    
    try {
      setLoading(true, 'Fetching data...');
      
      final results = await _firestoreService.fullSync();
      
      if (results['success'] == true) {
        // Update local data with cloud data
        if (results['progress'] != null) {
          _progressHistory = results['progress'] as List<DailyProgressModel>;
          await _storage.saveProgressData(_progressHistory);
        }
        
        if (results['goals'] != null) {
          _currentGoals = results['goals'] as DailyGoals;
          await _storage.saveGoals(_currentGoals!.toJson());
        }
        
        if (results['workoutHistory'] != null) {
          _workoutHistory = results['workoutHistory'] as List<WorkoutHistoryEntry>;
          await _storage.saveWorkoutHistory(
            _workoutHistory.map((e) => e.toJson()).toList(),
          );
        }
        
        setLoading(false);
        notifyListeners();
        return true;
      }
      
      setLoading(false);
      return false;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }
}

/// Provider widget for AppState
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }

  static AppState? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    return provider?.notifier;
  }
}
