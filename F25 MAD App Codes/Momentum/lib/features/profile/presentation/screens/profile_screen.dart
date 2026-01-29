import 'package:flutter/material.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/widgets/profile_picture_widget.dart';
import 'package:momentum/core/widgets/animated_list_item.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:momentum/features/profile/presentation/screens/settings_screen.dart';
import 'package:momentum/features/auth/presentation/screens/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final userName = appState.userName;
    final userEmail = appState.userEmail;
    final localUser = appState.localUserData;

    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              AnimatedScaleIn(
                delay: const Duration(milliseconds: 100),
                child: ProfilePictureWidget(
                  imagePath: localUser?.profileImagePath,
                  name: userName.isNotEmpty ? userName : 'Guest',
                  size: 120,
                  showEditButton: false,
                  borderWidth: 3,
                  borderColor: const Color(0xFFE8FF78),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  userName.isNotEmpty ? userName : 'Guest User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedFadeIn(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  userEmail.isNotEmpty ? userEmail : 'guest@momentum.app',
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedListItem(
                index: 0,
                child: _buildProfileDetailCard(
                  title: 'Weight',
                  value: localUser?.weight != null 
                      ? '${localUser!.weight!.toStringAsFixed(0)} ${localUser.useMetricUnits ? 'kg' : 'lbs'}' 
                      : 'Not set',
                ),
              ),
              const SizedBox(height: 16),
              AnimatedListItem(
                index: 1,
                child: _buildProfileDetailCard(
                  title: 'Height',
                  value: localUser?.height != null 
                      ? _formatHeight(localUser!.height!, localUser.useMetricUnits) 
                      : 'Not set',
                ),
              ),
              const SizedBox(height: 16),
              AnimatedListItem(
                index: 2,
                child: _buildProfileDetailCard(
                  title: 'Age',
                  value: localUser?.age != null ? '${localUser!.age}' : 'Not set',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Color(0xFF201A3F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _handleLogout(context),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHeight(double inches, bool useMetric) {
    if (useMetric) {
      final cm = inches * 2.54;
      return '${cm.toStringAsFixed(0)} cm';
    } else {
      final feet = (inches / 12).floor();
      final remainingInches = (inches % 12).round();
      return "$feet'$remainingInches\"";
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final appState = AppStateProvider.of(context);
              await appState.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  FadePageRoute(page: const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
