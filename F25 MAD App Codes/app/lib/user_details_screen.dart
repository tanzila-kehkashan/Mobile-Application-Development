import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/chat_service.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'edit_profile_screen.dart';
import 'chat_conversation_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final String? userId; // Optional - if null, shows current user

  const UserDetailsScreen({super.key, this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  UserModel? _user;
  bool _isLoading = true;
  bool _isCurrentUser = false;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final targetUserId = widget.userId ?? currentUserId;

    if (targetUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _isCurrentUser = targetUserId == currentUserId;

    try {
      final user = await _firestoreService.getUser(targetUserId);
      
      // Check if current user is following this user
      if (!_isCurrentUser && currentUserId != null && user != null) {
        _isFollowing = user.followers.contains(currentUserId);
      }
      
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null || _isFollowLoading) return;
    
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() => _isFollowLoading = true);

    try {
      if (_isFollowing) {
        await _firestoreService.unfollowUser(currentUserId, _user!.uid);
      } else {
        await _firestoreService.followUser(currentUserId, _user!.uid);
      }
      
      // Reload user to get updated follower count
      await _loadUser();
      
      setState(() {
        _isFollowing = !_isFollowing;
        _isFollowLoading = false;
      });
    } catch (e) {
      setState(() => _isFollowLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFB4A8A9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  SlidePageRoute(
                    page: const EditProfileScreen(),
                  ),
                );
                if (result == true) {
                  _loadUser(); // Refresh data
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCBB8A1)),
              ),
            )
          : _user == null
              ? _buildNoUserView()
              : _buildProfileView(),
    );
  }

  Widget _buildNoUserView() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage:
                currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null,
            child: currentUser?.photoURL == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            currentUser?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          if (_isCurrentUser)
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  SlidePageRoute(page: const EditProfileScreen()),
                );
                if (result == true) {
                  _loadUser();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Complete Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCBB8A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Profile Image with Online Status Indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage:
                    _user!.photoUrl != null ? NetworkImage(_user!.photoUrl!) : null,
                child: _user!.photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              // Online status indicator (Discord-style dot)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _user!.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Online status text
          Text(
            _user!.isOnline 
                ? 'Online' 
                : _user!.lastSeen != null 
                    ? 'Last seen ${_formatLastSeen(_user!.lastSeen!)}'
                    : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: _user!.isOnline ? Colors.green : Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          // Name
          Text(
            _user!.displayName ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 24),

          // Stats Row with stream for posts count
          StreamBuilder<List<PostModel>>(
            stream: _firestoreService.userPostsStream(_user!.uid),
            builder: (context, snapshot) {
              final postCount = snapshot.data?.length ?? 0;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem('Posts', '$postCount'),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildStatItem('Followers', '${_user!.followers.length}'),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildStatItem('Following', '${_user!.following.length}'),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Bio
          if (_user!.bio != null && _user!.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _user!.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // University & Major
          if (_user!.university != null || _user!.major != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_user!.university != null)
                    Row(
                      children: [
                        const Icon(Icons.school, size: 20, color: Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _user!.university!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  if (_user!.university != null && _user!.major != null)
                    const SizedBox(height: 12),
                  if (_user!.major != null)
                    Row(
                      children: [
                        const Icon(Icons.book, size: 20, color: Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _user!.major!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Action Buttons for non-current users
          if (!_isCurrentUser) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isFollowLoading ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing 
                            ? Colors.grey.shade300 
                            : const Color(0xFFCBB8A1),
                        foregroundColor: _isFollowing ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isFollowLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isFollowing ? 'Following' : 'Follow'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) return;
                        
                        // Get or create conversation
                        final conversationId = await _chatService.getOrCreateConversation(
                          userId1: currentUser.uid,
                          userId2: _user!.uid,
                          user1Name: currentUser.displayName ?? 'User',
                          user2Name: _user!.displayName ?? 'User',
                          user1PhotoUrl: currentUser.photoURL,
                          user2PhotoUrl: _user!.photoUrl,
                        );
                        
                        if (mounted) {
                          Navigator.push(
                            context,
                            SlidePageRoute(
                              page: ChatConversationScreen(
                                conversationId: conversationId,
                                otherUserName: _user!.displayName ?? 'User',
                                otherUserPhotoUrl: _user!.photoUrl,
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // User's Posts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.grid_on, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Posts Grid
          StreamBuilder<List<PostModel>>(
            stream: _firestoreService.userPostsStream(_user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCBB8A1)),
                    ),
                  ),
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posts yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () {
                      // Show post details
                      _showPostDetails(post);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: post.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                post.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  post.caption ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showPostDetails(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.imageUrl != null)
                      Image.network(
                        post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: post.authorPhotoUrl != null
                                    ? NetworkImage(post.authorPhotoUrl!)
                                    : null,
                                child: post.authorPhotoUrl == null
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (post.caption != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              post.caption!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 20, color: Colors.red),
                              const SizedBox(width: 4),
                              Text('${post.likeCount}'),
                              const SizedBox(width: 16),
                              Icon(Icons.chat_bubble_outline, size: 20),
                              const SizedBox(width: 4),
                              Text('${post.commentCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 7) {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
