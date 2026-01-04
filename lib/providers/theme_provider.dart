import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Change to AsyncNotifierProvider
final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  // 2. The build method replaces the constructor for initialization
  @override
  Future<ThemeMode> build() async {
    return _loadThemeMode();
  }

  Future<ThemeMode> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_key);

    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // 3. Update state using AsyncValue.guard to handle errors automatically
  Future<void> setThemeMode(ThemeMode mode) async {
    state = const AsyncLoading(); // Optional: show loading state during save
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name); // Using .name for cleaner code
      return mode;
    });
  }

  Future<void> toggleDarkMode() async {
    // We use .value to get the current data safely
    final currentMode = state.value ?? ThemeMode.system;
    final newMode = currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Helper for UI logic
  bool isDarkMode(BuildContext context) {
    final currentMode = state.value ?? ThemeMode.system;
    if (currentMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return currentMode == ThemeMode.dark;
  }
}