import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/chat_service.dart';
import 'package:nexus/models/conversation_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'chat_conversation_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFB4A8A9);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement chat search
            },
          ),
        ],
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please sign in to view messages'))
          : StreamBuilder<List<ConversationModel>>(
              stream: _chatService.getConversations(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFCBB8A1)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a chat with other students!',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: const NewChatScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Start New Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCBB8A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return AnimatedListItem(
                      index: index,
                      child: _buildConversationCard(
                        context,
                        conversation,
                        currentUserId,
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            SlidePageRoute(page: const NewChatScreen()),
          );
        },
        backgroundColor: const Color(0xFFCBB8A1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    ConversationModel conversation,
    String currentUserId,
  ) {
    final otherUserName = conversation.getOtherParticipantName(currentUserId);
    final otherUserPhoto = conversation.getOtherParticipantPhoto(currentUserId);
    final lastMessage = conversation.lastMessage;
    final timeAgo = _formatTimeAgo(conversation.lastMessageAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(
            page: ChatConversationScreen(
              conversationId: conversation.id,
              otherUserName: otherUserName,
              otherUserPhotoUrl: otherUserPhoto,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage:
                  otherUserPhoto != null ? NetworkImage(otherUserPhoto) : null,
              child: otherUserPhoto == null
                  ? const Icon(Icons.person, color: Colors.black, size: 32)
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
