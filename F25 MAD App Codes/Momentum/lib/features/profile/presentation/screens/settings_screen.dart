import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:momentum/features/profile/presentation/screens/security_screen.dart';
import 'package:momentum/features/profile/presentation/screens/terms_conditions_screen.dart';
import 'package:momentum/features/profile/presentation/screens/help_center_screen.dart';
import 'package:momentum/features/profile/presentation/screens/about_app_screen.dart';
import 'package:momentum/features/auth/presentation/screens/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final userName = appState.userName;
    final userEmail = appState.userEmail;
    final notificationsEnabled = appState.notificationsEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(
                icon: Icons.person,
                title: 'Personal Information',
                subtitle: '${userName.isNotEmpty ? userName : 'Guest'}, ${userEmail.isNotEmpty ? userEmail : 'Not logged in'}',
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const EditProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Password, biometrics, account',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const SecurityScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildNotificationSetting(notificationsEnabled, appState),
              const SizedBox(height: 10),
              // Cloud Sync Button
              if (appState.isLoggedIn)
                GestureDetector(
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Syncing data...'),
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    final success = await appState.syncToCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Data synced successfully!' : 'Sync failed. Please try again.',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3D7E),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_sync, color: Colors.white),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sync Data',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sync progress & history to cloud',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.sync, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              const Text(
                'Support & Legal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(
                icon: Icons.help_center,
                title: 'Help Center',
                subtitle: 'FAQs, contact support',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const HelpCenterScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(
                icon: Icons.article,
                title: 'Terms and Conditions',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const TermsConditionsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSettingsCard(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const AboutAppScreen()),
                  );
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3D7E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3D7E),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSetting(bool enabled, AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 16),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Switch(
            value: enabled,
            onChanged: (bool value) async {
              if (value) {
                // Request notification permission
                final status = await Permission.notification.request();
                if (status.isGranted) {
                  appState.setNotificationsEnabled(true);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications enabled!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else if (status.isPermanentlyDenied) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enable notifications in device settings'),
                      ),
                    );
                    openAppSettings();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification permission denied'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                appState.setNotificationsEnabled(false);
              }
              setState(() {});
            },
            thumbColor: WidgetStateProperty.all(Colors.white),
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A3D7E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await appState.logout();
                if (dialogContext.mounted) {
                  Navigator.pushAndRemoveUntil(
                    dialogContext,
                    FadePageRoute(page: const WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
