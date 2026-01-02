import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  /// Save user details locally
  Future<void> saveUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
  }

  /// Get user details locally
  /// Returns a Map with 'name' and 'email' keys, or null values if not found.
  Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);
    return {
      'name': name,
      'email': email,
    };
  }

  /// Clear user details locally (e.g. on logout)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
  }
}
