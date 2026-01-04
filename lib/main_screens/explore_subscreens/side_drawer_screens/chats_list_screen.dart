import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(time);
    } else if (difference. inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE'). format(time);
    } else {
      return DateFormat('MMM d'). format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final currentUser = ref.watch(authStateProvider). value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. search, color: Colors.black87),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 80,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants
                  .firstWhere((id) => id != currentUser?.uid, orElse: () => '');

              if (otherUserId. isEmpty) {
                return const SizedBox. shrink();
              }

              final otherUserDetails = chat.participantDetails[otherUserId] ??  {};
              final unreadCount = chat.unreadCount[currentUser?.uid] ?? 0;

              return _buildChatItem(
                context,
                ref,
                chatId: chat.id,
                name: otherUserDetails['name'] ?? 'Unknown User',
                lastMessage: chat.lastMessage,
                time: _formatTime(chat.lastMessageTime),
                unreadCount: unreadCount,
                otherUserId: otherUserId,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5B4EFF)),
        ),
        error: (error, stack) {
          // Check if it's an index error
          if (error. toString().contains('index') ||
              error.toString().contains('FAILED_PRECONDITION')) {
            return _buildIndexErrorState();
          }
          return _buildErrorState(error. toString());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInfoDialog(context);
        },
        backgroundColor: const Color(0xFF5B4EFF),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(
      BuildContext context,
      WidgetRef ref, {
        required String chatId,
        required String name,
        required String lastMessage,
        required String time,
        required int unreadCount,
        required String otherUserId,
      }) {
    return InkWell(
      onTap: () {
        Navigator. push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: otherUserId,
              otherUserName: name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment. spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors. black87,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage. isEmpty ? 'No messages yet' : lastMessage,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B4EFF),
                            borderRadius: BorderRadius. circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors. white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a chat with someone',
            style: TextStyle(fontSize: 14, color: Colors. grey[500]),
          ),
          const SizedBox(height: 24),
          Text(
            'Visit an organizer\'s profile and tap\n"Messages" to start chatting',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndexErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'Database Index Required',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A Firebase index is needed for the chat feature.  Please check the console logs for the index creation link.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Fix:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors. orange[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Check the app console/logs\n2. Find the Firebase index link\n3. Click the link to create the index\n4. Wait a few minutes\n5. Restart the app',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Unable to load chats',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Error details: ${error.length > 100 ? error.substring(0, 100) + '...' : error}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start a New Chat'),
        content: const Text(
          'To start a new chat, visit an organizer\'s profile from the Events screen and tap the "Messages" button.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF5B4EFF)),
            ),
          ),
        ],
      ),
    );
  }
}