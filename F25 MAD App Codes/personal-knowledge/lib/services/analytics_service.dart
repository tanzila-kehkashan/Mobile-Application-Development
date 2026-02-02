import 'package:firebase_analytics/firebase_analytics.dart';

/// Service class for Firebase Analytics
/// Handles event logging and user property tracking
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ============ SCREEN TRACKING ============

  /// Log a screen view event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      throw Exception('Failed to log screen view: $e');
    }
  }

  // ============ CUSTOM EVENTS ============

  /// Log a custom event with optional parameters
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      throw Exception('Failed to log event: $e');
    }
  }

  // ============ USER AUTHENTICATION EVENTS ============

  /// Log user sign up event
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
    } catch (e) {
      throw Exception('Failed to log sign up: $e');
    }
  }

  /// Log user login event
  Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
    } catch (e) {
      throw Exception('Failed to log login: $e');
    }
  }

  // ============ APP-SPECIFIC EVENTS ============

  /// Log when a user creates a note
  Future<void> logNoteCreated({
    String? noteType,
    int? noteLength,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'note_created',
        parameters: {
          if (noteType != null) 'note_type': noteType,
          if (noteLength != null) 'note_length': noteLength,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to log note creation: $e');
    }
  }

  /// Log when a user edits a note
  Future<void> logNoteEdited({
    String? noteId,
    int? editDuration,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'note_edited',
        parameters: {
          if (noteId != null) 'note_id': noteId,
          if (editDuration != null) 'edit_duration_seconds': editDuration,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to log note edit: $e');
    }
  }

  /// Log when a user deletes a note
  Future<void> logNoteDeleted({String? noteId}) async {
    try {
      await _analytics.logEvent(
        name: 'note_deleted',
        parameters: {
          if (noteId != null) 'note_id': noteId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to log note deletion: $e');
    }
  }

  /// Log when a user searches
  Future<void> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      throw Exception('Failed to log search: $e');
    }
  }

  /// Log when a user shares content
  Future<void> logShare({
    required String contentType,
    required String method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        method: method,
        itemId: 'note',
      );
    } catch (e) {
      throw Exception('Failed to log share: $e');
    }
  }

  // ============ USER PROPERTIES ============

  /// Set a user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      throw Exception('Failed to set user property: $e');
    }
  }

  /// Set the user ID
  Future<void> setUserId({required String userId}) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      throw Exception('Failed to set user ID: $e');
    }
  }

  /// Clear the user ID (on logout)
  Future<void> clearUserId() async {
    try {
      await _analytics.setUserId(id: null);
    } catch (e) {
      throw Exception('Failed to clear user ID: $e');
    }
  }

  // ============ APP LIFECYCLE EVENTS ============

  /// Log app open event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      throw Exception('Failed to log app open: $e');
    }
  }

  /// Log tutorial begin
  Future<void> logTutorialBegin() async {
    try {
      await _analytics.logTutorialBegin();
    } catch (e) {
      throw Exception('Failed to log tutorial begin: $e');
    }
  }

  /// Log tutorial complete
  Future<void> logTutorialComplete() async {
    try {
      await _analytics.logTutorialComplete();
    } catch (e) {
      throw Exception('Failed to log tutorial complete: $e');
    }
  }

  // ============ CONFIGURATION ============

  /// Enable analytics collection
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      throw Exception('Failed to set analytics collection: $e');
    }
  }

  /// Reset analytics data (useful for testing)
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
    } catch (e) {
      throw Exception('Failed to reset analytics data: $e');
    }
  }
}
