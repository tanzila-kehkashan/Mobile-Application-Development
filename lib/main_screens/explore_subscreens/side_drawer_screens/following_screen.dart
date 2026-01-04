import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/follow_provider.dart';
import '../../../providers/auth_provider.dart';

class FollowingScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const FollowingScreen({
    Key? key,
    required this.userId,
    this.userName = 'User',
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$userName\'s Following',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: followingAsync.when(
        data: (following) {
          if (following.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not Following Anyone Yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: following.length,
            itemBuilder: (context, index) {
              final user = following[index];
              return _buildUserCard(context, user, ref);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4EFF),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading following',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final isCurrentUser = currentUser?.uid == user['userId'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage: user['photoURL'] != null && user['photoURL'].isNotEmpty
                  ? NetworkImage(user['photoURL'])
                  : null,
              child: user['photoURL'] == null || user['photoURL'].isEmpty
                  ? Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 12),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['displayName'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Following',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Unfollow Button
            if (!isCurrentUser)
              OutlinedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Unfollow User'),
                      content: Text('Are you sure you want to unfollow ${user['displayName']}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Unfollow'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && currentUser != null) {
                    final followService = ref.read(followServiceProvider);
                    try {
                      await followService.unfollowUser(
                        currentUserId: currentUser.uid,
                        targetUserId: user['userId'],
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unfollowed successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Following',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
