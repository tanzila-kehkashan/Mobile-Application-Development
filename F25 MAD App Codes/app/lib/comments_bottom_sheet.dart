import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:nexus/models/comment_model.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';

/// Bottom sheet for displaying and adding comments to a post
class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: postId),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = _commentController.text;
    final selection = _commentController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, emoji.emoji);
    _commentController.text = newText;
    _commentController.selection = TextSelection.collapsed(
      offset: start + emoji.emoji.length,
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final comment = CommentModel(
        id: '',
        postId: widget.postId,
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        authorPhotoUrl: user.photoURL,
        text: text,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addComment(comment);
      _commentController.clear();
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7 + (_showEmojiPicker ? 250 : 0),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themeProvider.secondaryTextColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _firestoreService.commentsStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: themeProvider.secondaryTextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _CommentTile(
                      comment: comments[index],
                      themeProvider: themeProvider,
                      onDelete: () => _deleteComment(comments[index]),
                    );
                  },
                );
              },
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, _showEmojiPicker ? 8 : bottomPadding + 8),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji toggle button
                IconButton(
                  onPressed: _toggleEmojiPicker,
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard : Icons.sentiment_satisfied_alt_outlined,
                    color: themeProvider.secondaryTextColor,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? themeProvider.secondaryBackgroundColor 
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      style: TextStyle(color: themeProvider.textColor),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                          ),
                        )
                      : Icon(Icons.send, color: themeProvider.primaryColor),
                ),
              ],
            ),
          ),

          // Emoji Picker
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: _onEmojiSelected,
                config: Config(
                  height: 250,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                    backgroundColor: themeProvider.cardColor,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: themeProvider.cardColor,
                    indicatorColor: themeProvider.primaryColor,
                    iconColorSelected: themeProvider.primaryColor,
                    iconColor: themeProvider.secondaryTextColor,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    enabled: false,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: themeProvider.cardColor,
                    buttonIconColor: themeProvider.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (comment.authorId != currentUserId) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteComment(comment.id, widget.postId);
    }
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final ThemeProvider themeProvider;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.themeProvider,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = comment.authorId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: themeProvider.primaryColor,
            backgroundImage: comment.authorPhotoUrl != null
                ? NetworkImage(comment.authorPhotoUrl!)
                : null,
            child: comment.authorPhotoUrl == null
                ? const Icon(Icons.person, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textColor,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner)
            IconButton(
              icon: Icon(Icons.more_vert, size: 18, color: themeProvider.secondaryTextColor),
              onPressed: onDelete,
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
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

