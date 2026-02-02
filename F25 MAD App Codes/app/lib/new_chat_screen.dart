import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/chat_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'chat_conversation_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final users = await _firestoreService.getAllUsers(excludeUid: currentUserId);
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = []; // Don't show users by default
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = []; // Show nothing when empty - only show on search
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredUsers = _allUsers
            .where((user) =>
                (user.displayName?.toLowerCase().contains(lowerQuery) ?? false) ||
                (user.username?.toLowerCase().contains(lowerQuery) ?? false))
            .toList();
      }
    });
  }

  Future<void> _startConversation(UserModel user) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final conversationId = await _chatService.getOrCreateConversation(
        userId1: currentUser.uid,
        userId2: user.uid,
        user1Name: currentUser.displayName ?? 'You',
        user2Name: user.displayName ?? 'Unknown',
        user1PhotoUrl: currentUser.photoURL,
        user2PhotoUrl: user.photoUrl,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(
            page: ChatConversationScreen(
              conversationId: conversationId,
              otherUserName: user.displayName ?? 'Unknown',
              otherUserPhotoUrl: user.photoUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchByExactUsername(String username) async {
    // Remove @ symbol if user included it
    final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
    
    setState(() => _isLoading = true);

    try {
      final user = await _firestoreService.getUserByUsername(cleanUsername);
      
      if (!mounted) return;
      
      if (user != null) {
        // Check if this is the current user
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (user.uid == currentUserId) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You can't start a chat with yourself!"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        // Start conversation with the found user
        await _startConversation(user);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user found with username @$cleanUsername'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching for user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.secondaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Chat',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: 'Search by name or username...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFCBB8A1)),
                    ),
                  )
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Search for users'
                                  : 'No matching users',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Type a name or username to find people'
                                  : 'Try searching by exact username',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _searchByExactUsername(_searchController.text),
                                icon: const Icon(Icons.alternate_email),
                                label: Text('Find @${_searchController.text}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCBB8A1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserTile(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return GestureDetector(
      onTap: () => _startConversation(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, color: Colors.black, size: 28)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.username != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (user.university != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.university!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBB8A1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
