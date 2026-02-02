import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:nexus/services/chat_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/models/message_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isSending = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    // Mark messages as read when opening conversation
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _chatService.markMessagesAsRead(widget.conversationId, currentUserId);
    }
    
    // Listen for focus changes to hide emoji picker
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
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
    final text = _messageController.text;
    final selection = _messageController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji.emoji,
    );
    _messageController.text = newText;
    _messageController.selection = TextSelection.collapsed(
      offset: selection.start + emoji.emoji.length,
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _pickFromGallery();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.audiotrack,
                      label: 'Audio',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _pickAudio();
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam,
                      label: 'Video',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideo();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        _handleSelectedMedia(File(image.path), 'image');
      }
    } catch (e) {
      _showError('Error accessing camera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        for (var image in images) {
          _handleSelectedMedia(File(image.path), 'image');
        }
      }
    } catch (e) {
      _showError('Error picking from gallery: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        _handleSelectedMedia(File(video.path), 'video');
      }
    } catch (e) {
      _showError('Error picking video: $e');
    }
  }

  Future<void> _pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        _handleSelectedMedia(File(result.files.single.path!), 'audio');
      }
    } catch (e) {
      _showError('Error picking audio: $e');
    }
  }

  void _handleSelectedMedia(File file, String type) {
    // For now, show a confirmation that media was selected
    // In a full implementation, this would upload to Firebase Storage 
    // and send as a media message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected $type: ${file.path.split('/').last}'),
          backgroundColor: const Color(0xFFCBB8A1),
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        content: content,
      );

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: themeProvider.secondaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondaryBackgroundColor,
        elevation: 0,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: themeProvider.cardColor,
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? NetworkImage(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? Icon(Icons.person, color: themeProvider.textColor, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: themeProvider.textColor),
            onPressed: () {
              // TODO: Show chat options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: currentUserId == null
                ? Center(child: Text('Please sign in', style: TextStyle(color: themeProvider.textColor)))
                : StreamBuilder<List<MessageModel>>(
                    stream: _chatService.getMessages(widget.conversationId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
                          ),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: themeProvider.secondaryTextColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: themeProvider.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Say hello! 👋',
                                style: TextStyle(
                                  color: themeProvider.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          return _buildMessageBubble(message, isMe, themeProvider);
                        },
                      );
                    },
                  ),
          ),

          // Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeProvider.secondaryBackgroundColor,
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
                  // Message Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard
                                  : Icons.sentiment_satisfied_alt_outlined,
                              color: themeProvider.secondaryTextColor,
                            ),
                            onPressed: _toggleEmojiPicker,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(color: themeProvider.textColor),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: themeProvider.secondaryTextColor,
                            ),
                            onPressed: _showAttachmentOptions,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSending ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildMessageBubble(MessageModel message, bool isMe, ThemeProvider themeProvider) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? themeProvider.primaryColor : themeProvider.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : themeProvider.textColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : themeProvider.secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue.shade200 : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

