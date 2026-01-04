import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Back action
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: userDataAsync.when(
        data: (userData) => _buildProfileContent(userData, currentUser?. uid ??  ''),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4EFF),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic>? userData, String userId) {
    final name = userData?['name'] ?? 'Guest User';
    final bio = userData? ['bio'] ?? '';
    final following = userData?['following'] ?? 0;
    final followers = userData?['followers'] ?? 0;
    final interests = List<String>.from(userData?['interests'] ?? []);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Picture
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: const Color(0xFF5B4EFF),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Color(0xFF5B4EFF),
                ),
                onPressed: () => _showEditNameDialog(context, userId, name),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(following. toString(), 'Following'),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                _buildStatItem(followers. toString(), 'Followers'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton. icon(
              onPressed: () => _showEditProfileDialog(context, userId, name, bio),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5B4EFF),
                side: const BorderSide(
                  color: Color(0xFF5B4EFF),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double. infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // About Me Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Color(0xFF5B4EFF),
                      ),
                      onPressed: () => _showEditBioDialog(context, userId, bio),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bio. isEmpty
                      ? 'No bio yet.  Tap the edit button to add one.'
                      : bio,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: bio.isEmpty ? FontStyle.italic : FontStyle.normal,
                    color: bio.isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Interest Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Color(0xFF5B4EFF),
                      ),
                      onPressed: () => _showEditInterestsDialog(context, userId, interests),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                interests.isEmpty
                    ? Text(
                  'No interests added yet. Tap the edit button to add some.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                    : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: interests.map((interest) {
                    return _buildInterestChip(interest);
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    final colors = {
      'Gaming': const Color(0xFF00D9A5),
      'Clubbing': const Color(0xFFFF6B6B),
      'Concerts': const Color(0xFFFF9B57),
      'Music': const Color(0xFF5B4EFF),
      'Theater': const Color(0xFF00D9A5),
      'Art': const Color(0xFF4FC3F7),
      'Sports': const Color(0xFFFF6B6B),
      'Food': const Color(0xFF4CAF50),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colors[label] ?? const Color(0xFF5B4EFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Edit Name Dialog
  void _showEditNameDialog(BuildContext context, String userId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                try {
                  final userService = ref.read(userServiceProvider);
                  await userService.updateUserName(userId, newName);
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('Name updated successfully');
                  }
                } catch (e) {
                  _showSnackBar('Error updating name: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4EFF),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit Bio Dialog
  void _showEditBioDialog(BuildContext context, String userId, String currentBio) {
    final TextEditingController controller = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newBio = controller.text.trim();
              if (newBio != currentBio) {
                try {
                  final userService = ref.read(userServiceProvider);
                  await userService.updateUserBio(userId, newBio);
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('Bio updated successfully');
                  }
                } catch (e) {
                  _showSnackBar('Error updating bio: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4EFF),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit Profile Dialog (Name and Bio)
  void _showEditProfileDialog(
      BuildContext context,
      String userId,
      String currentName,
      String currentBio,
      ) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController bioController = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newBio = bioController. text.trim();

              if (newName.isEmpty) {
                _showSnackBar('Name cannot be empty', isError: true);
                return;
              }

              try {
                final userService = ref.read(userServiceProvider);
                await userService.updateUserProfile(
                  userId: userId,
                  name: newName != currentName ? newName : null,
                  bio: newBio != currentBio ? newBio : null,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Profile updated successfully');
                }
              } catch (e) {
                _showSnackBar('Error updating profile: $e', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4EFF),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit Interests Dialog
  void _showEditInterestsDialog(
      BuildContext context,
      String userId,
      List<String> currentInterests,
      ) {
    final List<String> availableInterests = [
      'Gaming',
      'Clubbing',
      'Concerts',
      'Music',
      'Theater',
      'Art',
      'Sports',
      'Food',
      'Travel',
      'Reading',
      'Photography',
      'Dancing',
    ];

    final List<String> selectedInterests = List.from(currentInterests);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Interests'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: availableInterests.map((interest) {
                final isSelected = selectedInterests.contains(interest);
                return CheckboxListTile(
                  title: Text(interest),
                  value: isSelected,
                  activeColor: const Color(0xFF5B4EFF),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedInterests.add(interest);
                      } else {
                        selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userService = ref.read(userServiceProvider);
                  await userService.updateUserInterests(userId, selectedInterests);
                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar('Interests updated successfully');
                  }
                } catch (e) {
                  _showSnackBar('Error updating interests: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4EFF),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius. vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // Share action
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final auth = ref.read(firebaseAuthProvider);
                await auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF5B4EFF),
      ),
    );
  }
}