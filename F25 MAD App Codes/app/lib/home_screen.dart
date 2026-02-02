import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'package:nexus/comments_bottom_sheet.dart';
import 'menu_screen.dart';
import 'notification_screen.dart';
import 'create_post_screen.dart';
import 'user_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.secondaryBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: themeProvider.isDarkMode 
            ? SystemUiOverlayStyle.light 
            : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu Icon
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(page: const MenuScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                width: 28,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: themeProvider.textColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // HOME title
                    Text(
                      'HOME',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    // Notification Icon
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: themeProvider.textColor,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(page: const NotificationScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Feed
              Expanded(
                child: StreamBuilder<List<PostModel>>(
                  stream: _firestoreService.postsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: themeProvider.textColor),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: themeProvider.textColor),
                            ),
                          ],
                        ),
                      );
                    }

                    final posts = snapshot.data ?? [];

                    if (posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 80,
                              color: themeProvider.textColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No posts yet',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share something!',
                              style: TextStyle(
                                color: themeProvider.textColor.withValues(alpha: 0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        // Stream auto-refreshes, just simulate a delay
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        itemCount: posts.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return AnimatedListItem(
                            index: index,
                            child: PostCard(
                              post: posts[index],
                              currentUserId: currentUserId,
                              themeProvider: themeProvider,
                              onLikeToggle: () async {
                                if (currentUserId == null) return;
                                final post = posts[index];
                                if (post.isLikedBy(currentUserId)) {
                                  await _firestoreService.unlikePost(
                                      post.id, currentUserId);
                                } else {
                                  await _firestoreService.likePost(
                                      post.id, currentUserId);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleAnimation(
        delay: const Duration(milliseconds: 500),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ScaleOnTap(
            onTap: () {
              Navigator.push(
                context,
                SlideUpPageRoute(page: const CreatePostScreen()),
              );
            },
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;
  final String? currentUserId;
  final ThemeProvider themeProvider;
  final VoidCallback onLikeToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.themeProvider,
    required this.onLikeToggle,
  });

  void _navigateToUserDetails(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(page: UserDetailsScreen(userId: post.authorId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = currentUserId != null && post.isLikedBy(currentUserId!);

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      color: themeProvider.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserDetails(context),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: themeProvider.isDarkMode 
                        ? themeProvider.secondaryBackgroundColor 
                        : const Color(0xFFE0E0E0),
                    backgroundImage: post.authorPhotoUrl != null
                        ? NetworkImage(post.authorPhotoUrl!)
                        : null,
                    child: post.authorPhotoUrl == null
                        ? Icon(Icons.person, color: themeProvider.textColor, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToUserDetails(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: TextStyle(
                            color: themeProvider.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // More options
                IconButton(
                  icon: Icon(Icons.more_vert, color: themeProvider.secondaryTextColor),
                  onPressed: () => _showPostOptions(context),
                ),
              ],
            ),
          ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                post.caption!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: themeProvider.textColor,
                ),
              ),
            ),

          // Image
          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : themeProvider.textColor,
                    size: 26,
                  ),
                  onPressed: onLikeToggle,
                ),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(width: 16),

                // Comment button
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline, 
                    size: 24,
                    color: themeProvider.textColor,
                  ),
                  onPressed: () {
                    CommentsBottomSheet.show(context, post.id);
                  },
                ),
                Text(
                  '${post.commentCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textColor,
                  ),
                ),

                const Spacer(),

                // Share button
                IconButton(
                  icon: Icon(
                    Icons.share_outlined, 
                    size: 24,
                    color: themeProvider.textColor,
                  ),
                  onPressed: () => _sharePost(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            if (currentUserId == post.authorId)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeletePostDialog(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    String? selectedReason;
    final reasons = [
      'Spam or misleading',
      'Harassment or bullying',
      'Inappropriate content',
      'Violence or dangerous content',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Why are you reporting this post?'),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (value) => setState(() => selectedReason = value),
                child: Column(
                  children: reasons.map((reason) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Radio<String>(value: reason),
                    title: Text(reason, style: const TextStyle(fontSize: 14)),
                    onTap: () => setState(() => selectedReason = reason),
                  )).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _submitReport(context, selectedReason!);
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reason) async {
    if (currentUserId == null) return;

    try {
      await FirestoreService().reportPost(
        postId: post.id,
        reporterId: currentUserId!,
        reason: reason,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you for helping keep our community safe.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeletePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirestoreService().deletePost(post.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting post: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sharePost(BuildContext context) async {
    String shareText = '';
    
    if (post.caption != null && post.caption!.isNotEmpty) {
      shareText = post.caption!;
    }
    
    if (post.imageUrl != null) {
      if (shareText.isNotEmpty) {
        shareText += '\n\n';
      }
      shareText += post.imageUrl!;
    }
    
    if (shareText.isEmpty) {
      shareText = 'Check out this post on Nexus!';
    } else {
      shareText += '\n\n- Shared from Nexus';
    }

    try {
      await Share.share(shareText);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
