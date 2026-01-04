import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_preferences_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final NotificationPreferencesService _prefsService = NotificationPreferencesService();
  
  bool _notificationsEnabled = true;
  bool _eventNotifications = true;
  bool _socialNotifications = true;
  bool _bookingNotifications = true;
  bool _messageNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is mounted before reading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPreferences();
      }
    });
  }
  
  Future<void> _loadPreferences() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      try {
        final prefs = await _prefsService.getPreferencesOnce(user.uid);
        if (mounted) {
          setState(() {
            _notificationsEnabled = prefs['pushNotifications'] ?? true;
            _eventNotifications = prefs['eventNotifications'] ?? true;
            _socialNotifications = prefs['socialNotifications'] ?? true;
            _bookingNotifications = prefs['bookingNotifications'] ?? true;
            _messageNotifications = prefs['messageNotifications'] ?? true;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading preferences: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _savePreferences() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      try {
        await _prefsService.savePreferences(user.uid, {
          'pushNotifications': _notificationsEnabled,
          'eventNotifications': _eventNotifications,
          'socialNotifications': _socialNotifications,
          'bookingNotifications': _bookingNotifications,
          'messageNotifications': _messageNotifications,
        });
      } catch (e) {
        print('Error saving preferences: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
      (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4EFF),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your profile information',
            onTap: () {
              // Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: Text(isDarkMode ? 'Dark theme enabled' : 'Light theme enabled'),
            value: isDarkMode,
            activeColor: const Color(0xFF5B4EFF),
            onChanged: (value) async {
              await ref.read(themeModeProvider.notifier).toggleDarkMode();
            },
          ),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            subtitle: const Text('Enable or disable all notifications'),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF5B4EFF),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _savePreferences();
            },
          ),
          if (_notificationsEnabled) ...[
            _buildSubSwitchTile(
              title: 'Event Notifications',
              subtitle: 'Updates about events you\'re interested in',
              value: _eventNotifications,
              onChanged: (value) {
                setState(() {
                  _eventNotifications = value;
                });
                _savePreferences();
              },
            ),
            _buildSubSwitchTile(
              title: 'Social Notifications',
              subtitle: 'Followers and social interactions',
              value: _socialNotifications,
              onChanged: (value) {
                setState(() {
                  _socialNotifications = value;
                });
                _savePreferences();
              },
            ),
            _buildSubSwitchTile(
              title: 'Booking Notifications',
              subtitle: 'Booking confirmations and updates',
              value: _bookingNotifications,
              onChanged: (value) {
                setState(() {
                  _bookingNotifications = value;
                });
                _savePreferences();
              },
            ),
            _buildSubSwitchTile(
              title: 'Message Notifications',
              subtitle: 'New messages and chat updates',
              value: _messageNotifications,
              onChanged: (value) {
                setState(() {
                  _messageNotifications = value;
                });
                _savePreferences();
              },
            ),
          ],
          const Divider(),

          // Privacy Section
          _buildSectionHeader('Privacy'),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy - Opening...')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.security_outlined,
            title: 'Data & Security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data & Security - Coming soon')),
              );
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service - Opening...')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support - Coming soon')),
              );
            },
          ),
          const Divider(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5B4EFF),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildSubSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        activeColor: const Color(0xFF5B4EFF),
        onChanged: onChanged,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'You will receive an email with instructions to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(authStateProvider).value;
              if (user?.email != null) {
                try {
                  final authService = ref.read(authServiceProvider);
                  await authService.sendPasswordResetEmail(user!.email!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authService = ref.read(authServiceProvider);
                await authService.signOutAndClearCredentials();
                Navigator.pop(context); // Close dialog
                // The authStateProvider will handle navigation to login screen
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
