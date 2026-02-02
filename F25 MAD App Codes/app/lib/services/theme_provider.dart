import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme modes available in the app
enum AppThemeMode {
  defaultTheme,
  protopia,    // Red-Green color blindness friendly
  deutropia,   // Blue-Yellow color blindness friendly
  custom,
}

/// Provider for app-wide theme management
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _customColorKey = 'custom_color';

  AppThemeMode _themeMode = AppThemeMode.defaultTheme;
  bool _isDarkMode = false;
  Color? _customColor;
  
  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  Color? get customColor => _customColor;

  ThemeProvider() {
    _loadPreferences();
  }

  /// Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    _themeMode = AppThemeMode.values[themeModeIndex];
    
    _isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    
    final customColorValue = prefs.getInt(_customColorKey);
    if (customColorValue != null) {
      _customColor = Color(customColorValue);
    }
    
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, value);
    notifyListeners();
  }

  /// Set custom color
  Future<void> setCustomColor(Color color) async {
    _customColor = color;
    _themeMode = AppThemeMode.custom;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customColorKey, color.toARGB32());
    await prefs.setInt(_themeModeKey, AppThemeMode.custom.index);
    notifyListeners();
  }

  /// Get primary color based on current theme
  Color get primaryColor {
    if (_customColor != null && _themeMode == AppThemeMode.custom) {
      return _customColor!;
    }
    
    switch (_themeMode) {
      case AppThemeMode.protopia:
        return const Color(0xFF2196F3); // Blue (safe for red-green blindness)
      case AppThemeMode.deutropia:
        return const Color(0xFF9C27B0); // Purple (safe for blue-yellow blindness)
      case AppThemeMode.defaultTheme:
      case AppThemeMode.custom:
        return const Color(0xFFCBB8A1); // Default app color
    }
  }

  /// Get background color based on theme and dark mode
  Color get backgroundColor {
    if (_isDarkMode) {
      return const Color(0xFF121212);
    }
    
    switch (_themeMode) {
      case AppThemeMode.protopia:
        return const Color(0xFFE3F2FD);
      case AppThemeMode.deutropia:
        return const Color(0xFFF3E5F5);
      case AppThemeMode.defaultTheme:
      case AppThemeMode.custom:
        return const Color(0xFFEBE3E3);
    }
  }

  /// Get secondary background color
  Color get secondaryBackgroundColor {
    if (_isDarkMode) {
      return const Color(0xFF1E1E1E);
    }
    
    switch (_themeMode) {
      case AppThemeMode.protopia:
        return const Color(0xFFBBDEFB);
      case AppThemeMode.deutropia:
        return const Color(0xFFE1BEE7);
      case AppThemeMode.defaultTheme:
      case AppThemeMode.custom:
        return const Color(0xFFB4A8A9);
    }
  }

  /// Get card color
  Color get cardColor {
    if (_isDarkMode) {
      return const Color(0xFF2C2C2C);
    }
    return Colors.white;
  }

  /// Get text color
  Color get textColor {
    return _isDarkMode ? Colors.white : Colors.black87;
  }

  /// Get secondary text color
  Color get secondaryTextColor {
    return _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Get app ThemeData
  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
