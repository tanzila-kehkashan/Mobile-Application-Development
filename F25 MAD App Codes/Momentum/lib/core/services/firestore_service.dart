import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/goals_model.dart';
import '../models/workout_history_model.dart';

/// Firebase Firestore service for cloud data synchronization
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _userId != null;

  // ==================== User Data ====================

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> _userDoc(String? userId) {
    return _firestore.collection('users').doc(userId ?? _userId);
  }

  /// Sync user profile to cloud
  Future<bool> syncUserData(UserModel user) async {
    if (!isAuthenticated) return false;
    
    try {
      await _userDoc(user.id).set({
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error syncing user data: $e');
      return false;
    }
  }

  /// Fetch user data from cloud
  Future<UserModel?> fetchUserData() async {
    if (!isAuthenticated) return null;
    
    try {
      final doc = await _userDoc(null).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // ==================== Progress Data ====================

  /// Get progress collection reference
  CollectionReference<Map<String, dynamic>> _progressCollection() {
    return _userDoc(null).collection('progress');
  }

  /// Sync progress data to cloud
  Future<bool> syncProgress(List<DailyProgressModel> progressList) async {
    if (!isAuthenticated) return false;
    
    try {
      final batch = _firestore.batch();
      
      for (final progress in progressList) {
        final docId = _dateToDocId(progress.date);
        final docRef = _progressCollection().doc(docId);
        batch.set(docRef, {
          ...progress.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error syncing progress: $e');
      return false;
    }
  }

  /// Sync single day progress
  Future<bool> syncDayProgress(DailyProgressModel progress) async {
    if (!isAuthenticated) return false;
    
    try {
      final docId = _dateToDocId(progress.date);
      await _progressCollection().doc(docId).set({
        ...progress.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error syncing day progress: $e');
      return false;
    }
  }

  /// Fetch progress data from cloud
  Future<List<DailyProgressModel>> fetchProgress({int limit = 90}) async {
    if (!isAuthenticated) return [];
    
    try {
      final snapshot = await _progressCollection()
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => DailyProgressModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching progress: $e');
      return [];
    }
  }

  // ==================== Goals ====================

  /// Sync goals to cloud
  Future<bool> syncGoals(DailyGoals goals) async {
    if (!isAuthenticated) return false;
    
    try {
      await _userDoc(null).collection('settings').doc('goals').set({
        ...goals.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error syncing goals: $e');
      return false;
    }
  }

  /// Fetch goals from cloud
  Future<DailyGoals?> fetchGoals() async {
    if (!isAuthenticated) return null;
    
    try {
      final doc = await _userDoc(null).collection('settings').doc('goals').get();
      if (doc.exists && doc.data() != null) {
        return DailyGoals.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching goals: $e');
      return null;
    }
  }

  // ==================== Workout History ====================

  /// Get workout history collection reference
  CollectionReference<Map<String, dynamic>> _historyCollection() {
    return _userDoc(null).collection('workout_history');
  }

  /// Add workout to history
  Future<bool> addWorkoutToHistory(WorkoutHistoryEntry entry) async {
    if (!isAuthenticated) return false;
    
    try {
      await _historyCollection().doc(entry.id).set({
        ...entry.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding workout to history: $e');
      return false;
    }
  }

  /// Sync workout history to cloud
  Future<bool> syncWorkoutHistory(List<WorkoutHistoryEntry> history) async {
    if (!isAuthenticated) return false;
    
    try {
      final batch = _firestore.batch();
      
      for (final entry in history) {
        final docRef = _historyCollection().doc(entry.id);
        batch.set(docRef, entry.toJson(), SetOptions(merge: true));
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error syncing workout history: $e');
      return false;
    }
  }

  /// Fetch workout history from cloud
  Future<List<WorkoutHistoryEntry>> fetchWorkoutHistory({int limit = 100}) async {
    if (!isAuthenticated) return [];
    
    try {
      final snapshot = await _historyCollection()
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => WorkoutHistoryEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching workout history: $e');
      return [];
    }
  }

  /// Clear workout history
  Future<bool> clearWorkoutHistory() async {
    if (!isAuthenticated) return false;
    
    try {
      final snapshot = await _historyCollection().get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error clearing workout history: $e');
      return false;
    }
  }

  // ==================== Full Sync ====================

  /// Perform full data sync from cloud
  Future<Map<String, dynamic>> fullSync() async {
    if (!isAuthenticated) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final results = await Future.wait([
        fetchUserData(),
        fetchProgress(),
        fetchGoals(),
        fetchWorkoutHistory(),
      ]);
      
      return {
        'success': true,
        'userData': results[0],
        'progress': results[1],
        'goals': results[2],
        'workoutHistory': results[3],
      };
    } catch (e) {
      debugPrint('Error during full sync: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== Helpers ====================

  /// Convert date to document ID
  String _dateToDocId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
