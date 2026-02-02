import 'package:flutter/material.dart';

/// Custom exception class for app-specific errors
class AppException implements Exception {
  final String code;
  final String message;
  final String? userFriendlyMessage;
  final dynamic originalError;

  AppException({
    required this.code,
    required this.message,
    this.userFriendlyMessage,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';

  /// Get the message to display to users
  String get displayMessage => userFriendlyMessage ?? message;
}

/// Centralized error handler for consistent error handling across the app
class ErrorHandler {
  /// Show an error snackbar
  static void showError(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show a warning snackbar
  static void showWarning(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFA726),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Show an info snackbar
  static void showInfo(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show an error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    if (!context.mounted) return;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A3D7E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onPressed?.call();
              },
              child: Text(
                buttonText ?? 'OK',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle exception and show appropriate message
  static void handleException(BuildContext context, dynamic error, {String? fallbackMessage}) {
    String message;
    
    if (error is AppException) {
      message = error.displayMessage;
    } else if (error.toString().contains('network')) {
      message = 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      message = 'Request timed out. Please try again.';
    } else {
      message = fallbackMessage ?? 'An unexpected error occurred. Please try again.';
    }
    
    showError(context, message);
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('socket') ||
           errorString.contains('connection') ||
           errorString.contains('timeout');
  }
}
