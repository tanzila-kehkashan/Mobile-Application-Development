import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_profile_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const Color blue = Color(0xFF007AFF);

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final profileService = UserProfileService();
    final User? currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
            child: const Text('help', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: profileService.streamUserProfile(),
        builder: (context, snapshot) {
          final profileData = snapshot.data;
          final profilePictureUrl = profileData?['profilePictureUrl'] as String?;
          final displayName = profileData?['displayName'] as String?;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: blue,
                  backgroundImage: (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: (profilePictureUrl == null || profilePictureUrl.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  displayName ?? currentUser?.displayName ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(label: 'Email', value: currentUser?.email ?? 'Not available'),
              const SizedBox(height: 16),
              _buildTextField(label: 'User ID', value: currentUser?.uid.substring(0, 20) ?? 'N/A'),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button with Firebase
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      try {
                        await authService.signOut();
                        
                        // Navigate to login screen
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,  // Remove all previous routes
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity, // Ensure full width
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Added vertical padding
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}