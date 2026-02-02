import 'package:flutter/material.dart';

/// Centralized app colors with helper methods
/// This replaces deprecated withOpacity calls throughout the app
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFFCBB8A1);
  static const Color primaryDark = Color(0xFFB4A5A5);
  static const Color background = Color(0xFFEBE3E3);
  static const Color backgroundDark = Color(0xFFB4A8A9);
  
  // Accent colors
  static const Color accent = Color(0xFF7C4DFF);
  static const Color accentSecondary = Color(0xFF536DFE);
  
  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF5A4C6B);
  static const Color textLight = Colors.white;
  
  // UI colors
  static const Color inputBackground = Color(0xFFEAE3D8);
  static const Color cardBackground = Color(0xFFD8D8D8);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Colors.red;
  static const Color warning = Color(0xFFFF9800);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF7C4DFF),
    Color(0xFF536DFE),
  ];
  
  static const List<Color> onboardingColors = [
    Color(0xFF7C4DFF),
    Color(0xFF536DFE),
    Color(0xFF00BCD4),
    Color(0xFF4CAF50),
  ];
}

/// Extension on Color to replace deprecated withOpacity
/// Uses withValues() which is the recommended approach in Flutter 3.x
extension ColorExtension on Color {
  /// Creates a new color with the specified alpha value (0.0 to 1.0)
  /// This is the recommended replacement for withOpacity
  Color withAlphaValue(double alpha) {
    return withValues(alpha: alpha);
  }
  
  /// Creates a color with 10% opacity
  Color get opacity10 => withValues(alpha: 0.1);
  
  /// Creates a color with 20% opacity
  Color get opacity20 => withValues(alpha: 0.2);
  
  /// Creates a color with 30% opacity
  Color get opacity30 => withValues(alpha: 0.3);
  
  /// Creates a color with 40% opacity
  Color get opacity40 => withValues(alpha: 0.4);
  
  /// Creates a color with 50% opacity
  Color get opacity50 => withValues(alpha: 0.5);
  
  /// Creates a color with 60% opacity
  Color get opacity60 => withValues(alpha: 0.6);
  
  /// Creates a color with 70% opacity
  Color get opacity70 => withValues(alpha: 0.7);
  
  /// Creates a color with 80% opacity
  Color get opacity80 => withValues(alpha: 0.8);
  
  /// Creates a color with 90% opacity
  Color get opacity90 => withValues(alpha: 0.9);
}

/// Predefined shadow styles
class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      spreadRadius: 1,
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ];
  
  static List<BoxShadow> get fab => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
    ),
  ];
  
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      spreadRadius: 5,
    ),
  ];
}
