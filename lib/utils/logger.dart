import 'dart:developer' as developer;

/// Simple logging utility for the EventHub app
class AppLogger {
  static const String _appName = 'EventHub';

  /// Log an info message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: '$_appName${tag != null ? '.$tag' : ''}',
      level: 800,
    );
  }

  /// Log an error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: '$_appName${tag != null ? '.$tag' : ''}',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: '$_appName${tag != null ? '.$tag' : ''}',
      level: 900,
    );
  }

  /// Log a debug message
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: '$_appName${tag != null ? '.$tag' : ''}',
      level: 700,
    );
  }
}
