import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/follow_provider.dart';
import '../../../providers/auth_provider.dart';

class FollowersScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const FollowersScreen({
    Key? key,
    required this.userId,
    this.userName = 'User',
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$userName\'s Followers',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: followersAsync.when(
        data: (followers) {
          if (followers.isEmpty) {
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
                    'No Followers Yet',
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
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final follower = followers[index];
              return _buildUserCard(context, follower, ref);
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
                'Error loading followers',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> follower, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final isCurrentUser = currentUser?.uid == follower['userId'];

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
              backgroundImage: follower['photoURL'] != null && follower['photoURL'].isNotEmpty
                  ? NetworkImage(follower['photoURL'])
                  : null,
              child: follower['photoURL'] == null || follower['photoURL'].isEmpty
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
                    follower['displayName'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Follower',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Follow/Following Button
            if (!isCurrentUser)
              _buildFollowButton(context, follower['userId'], ref),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, String targetUserId, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    
    if (currentUser == null) return const SizedBox.shrink();

    final isFollowingAsync = ref.watch(isFollowingProvider({
      'currentUserId': currentUser.uid,
      'targetUserId': targetUserId,
    }));

    return isFollowingAsync.when(
      data: (isFollowing) {
        return OutlinedButton(
          onPressed: () async {
            final followService = ref.read(followServiceProvider);
            try {
              if (isFollowing) {
                await followService.unfollowUser(
                  currentUserId: currentUser.uid,
                  targetUserId: targetUserId,
                );
              } else {
                await followService.followUser(
                  currentUserId: currentUser.uid,
                  targetUserId: targetUserId,
                );
              }
              // Refresh the provider
              ref.invalidate(isFollowingProvider({
                'currentUserId': currentUser.uid,
                'targetUserId': targetUserId,
              }));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: isFollowing ? Colors.grey : const Color(0xFF5B4EFF),
            side: BorderSide(
              color: isFollowing ? Colors.grey : const Color(0xFF5B4EFF),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 80,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
