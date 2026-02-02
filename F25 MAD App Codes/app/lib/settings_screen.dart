import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexus/services/auth_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _pushNotifications = true;
  bool _showOnlineStatus = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _requestNotificationPermission(bool value) async {
    if (value) {
      // Request permission
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        setState(() => _pushNotifications = true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('push_notifications', true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Push notifications enabled!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Please enable in device settings.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      setState(() => _pushNotifications = false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Push notifications disabled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _showOnlineStatus = value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_online_status', value);
    
    // Update online status in Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _firestoreService.updateOnlineStatus(userId, value ? true : false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Account Section
                  _buildSectionHeader('Account', themeProvider),
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'Email',
                    subtitle: user?.email ?? 'Not signed in',
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Email Verified',
                    subtitle: user?.emailVerified == true ? 'Verified' : 'Not verified',
                    trailing: user?.emailVerified != true
                        ? TextButton(
                            onPressed: () async {
                              await user?.sendEmailVerification();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification email sent!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('Verify'),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () => _showChangePasswordDialog(),
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications Section
                  _buildSectionHeader('Notifications', themeProvider),
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    value: _pushNotifications,
                    onChanged: _requestNotificationPermission,
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Privacy Section
                  _buildSectionHeader('Privacy', themeProvider),
                  _buildSwitchTile(
                    icon: Icons.visibility_outlined,
                    title: 'Show Online Status',
                    subtitle: 'Let others see when you\'re online',
                    value: _showOnlineStatus,
                    onChanged: _toggleOnlineStatus,
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Appearance Section
                  _buildSectionHeader('Appearance', themeProvider),
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) async {
                      await themeProvider.setDarkMode(value);
                    },
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Legal Section
                  _buildSectionHeader('Legal', themeProvider),
                  _buildListTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const TermsOfServiceScreen()),
                    ),
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const PrivacyPolicyScreen()),
                    ),
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Support Section
                  _buildSectionHeader('Support', themeProvider),
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.push(
                      context,
                      SlidePageRoute(page: const HelpSupportScreen()),
                    ),
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Delete Account
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      onPressed: () => _showDeleteAccountDialog(),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: themeProvider.secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(icon, color: themeProvider.textColor),
      title: Text(title, style: TextStyle(fontSize: 16, color: themeProvider.textColor)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: themeProvider.secondaryTextColor))
          : null,
      trailing: trailing ?? (onTap != null
          ? Icon(Icons.chevron_right, color: themeProvider.secondaryTextColor)
          : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(icon, color: themeProvider.textColor),
      title: Text(title, style: TextStyle(fontSize: 16, color: themeProvider.textColor)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: themeProvider.secondaryTextColor))
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: themeProvider.primaryColor,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.grey;
        }),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'We\'ll send you an email with instructions to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final email = FirebaseAuth.instance.currentUser?.email;
              if (email != null) {
                await _authService.sendPasswordResetEmail(email);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCBB8A1),
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  // Delete all user data first (posts, comments, etc.)
                  await _firestoreService.deleteAllUserData(userId);
                }
                // Then delete the auth account
                await FirebaseAuth.instance.currentUser?.delete();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  FadePageRoute(page: const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Terms of Service Screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms of Service',
          style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeProvider.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: December 2024',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using Nexus, you accept and agree to be bound by the terms and provisions of this agreement.',
              themeProvider,
            ),
            _buildSection(
              'Use of Service',
              'Nexus is a platform for university students to connect, share, and communicate. You agree to use the service only for lawful purposes and in accordance with these terms.',
              themeProvider,
            ),
            _buildSection(
              'User Accounts',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
              themeProvider,
            ),
            _buildSection(
              'Content Guidelines',
              'Users must not post content that is offensive, harmful, or violates the rights of others. We reserve the right to remove any content that violates these guidelines.',
              themeProvider,
            ),
            _buildSection(
              'Privacy',
              'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
              themeProvider,
            ),
            _buildSection(
              'Termination',
              'We reserve the right to terminate or suspend your account at any time for violations of these terms or for any other reason.',
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: themeProvider.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 15, color: themeProvider.secondaryTextColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeProvider.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: December 2024',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly, such as your name, email, and profile information. We also collect usage data to improve our services.',
              themeProvider,
            ),
            _buildSection(
              'How We Use Your Information',
              'We use your information to provide and improve our services, communicate with you, and ensure the security of our platform.',
              themeProvider,
            ),
            _buildSection(
              'Information Sharing',
              'We do not sell your personal information. We may share information with service providers who assist us in operating our platform.',
              themeProvider,
            ),
            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information from unauthorized access or disclosure.',
              themeProvider,
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, correct, or delete your personal information. Contact us to exercise these rights.',
              themeProvider,
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at raqeeb0318212@gmail.com',
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: themeProvider.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 15, color: themeProvider.secondaryTextColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _openEmailClient(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'raqeeb0318212@gmail.com',
      query: 'subject=Nexus App Support',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email client. Please email raqeeb0318212@gmail.com'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Contact Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 48, color: themeProvider.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Need Help?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is here to help you.',
                    style: TextStyle(color: themeProvider.secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openEmailClient(context),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.textColor),
            ),
            const SizedBox(height: 16),
            
            _buildFAQItem(
              'How do I create an account?',
              'Tap "Sign Up" on the welcome screen and enter your email, password, and profile information.',
              themeProvider,
            ),
            _buildFAQItem(
              'How do I reset my password?',
              'On the login screen, tap "Forget password?" and enter your email. We\'ll send you a reset link.',
              themeProvider,
            ),
            _buildFAQItem(
              'How do I start a chat?',
              'Go to the Chat section from the menu, and tap the + button to start a new conversation.',
              themeProvider,
            ),
            _buildFAQItem(
              'How do I post content?',
              'On the Home Feed, tap the + button to create a new post with text or images.',
              themeProvider,
            ),
            _buildFAQItem(
              'How do I delete my account?',
              'Go to Settings > scroll down to "Delete Account" and confirm the deletion.',
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: themeProvider.textColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: themeProvider.secondaryTextColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
