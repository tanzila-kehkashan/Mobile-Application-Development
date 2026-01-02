import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorBlindKey = 'color_blind_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isColorBlindMode = false;
  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;

  SettingsService() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isColorBlindMode => _isColorBlindMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load Color Blind Mode
    _isColorBlindMode = prefs.getBool(_colorBlindKey) ?? false;

    // Load Language
    final langCode = prefs.getString(_languageKey);
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    // Load Notifications
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }

  Future<void> toggleColorBlindMode(bool enabled) async {
    _isColorBlindMode = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_colorBlindKey, enabled);
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
}
