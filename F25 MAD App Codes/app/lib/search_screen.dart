import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/models/user_model.dart';
import 'package:nexus/models/post_model.dart';
import 'package:nexus/models/event_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'user_details_screen.dart';
import 'event_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  
  List<UserModel> _users = [];
  List<PostModel> _posts = [];
  List<EventModel> _events = [];
  
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _users = [];
        _posts = [];
        _events = [];
        _isSearching = false;
      });
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _isSearching = true);

    try {
      // Search all categories in parallel
      final results = await Future.wait([
        _firestoreService.searchUsers(query),
        _firestoreService.searchPosts(query),
        _firestoreService.searchEvents(query),
      ]);

      if (mounted && query == _lastQuery) {
        setState(() {
          _users = results[0] as List<UserModel>;
          _posts = results[1] as List<PostModel>;
          _events = results[2] as List<EventModel>;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
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
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      hintText: 'Search users, posts, events...',
                      hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
                      prefixIcon: Icon(Icons.search, color: themeProvider.secondaryTextColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: themeProvider.secondaryTextColor),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update clear button visibility
                      if (value.length >= 2) {
                        _performSearch(value);
                      } else if (value.isEmpty) {
                        _performSearch('');
                      }
                    },
                    onSubmitted: _performSearch,
                  ),
                ),
              ),
              
              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: themeProvider.textColor,
                unselectedLabelColor: themeProvider.secondaryTextColor,
                indicatorColor: themeProvider.primaryColor,
                tabs: [
                  Tab(text: 'Users (${_users.length})'),
                  Tab(text: 'Posts (${_posts.length})'),
                  Tab(text: 'Events (${_events.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isSearching
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(themeProvider),
                _buildPostsTab(themeProvider),
                _buildEventsTab(themeProvider),
              ],
            ),
    );
  }

  Widget _buildUsersTab(ThemeProvider themeProvider) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        message: 'Search for users',
        themeProvider: themeProvider,
      );
    }

    if (_users.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_off,
        message: 'No users found',
        themeProvider: themeProvider,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: themeProvider.primaryColor,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              user.displayName ?? 'Unknown',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            subtitle: Text(
              user.email,
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            trailing: Icon(Icons.chevron_right, color: themeProvider.secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: UserDetailsScreen(userId: user.uid)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsTab(ThemeProvider themeProvider) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        message: 'Search for posts',
        themeProvider: themeProvider,
      );
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        message: 'No posts found',
        themeProvider: themeProvider,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: themeProvider.primaryColor,
                  backgroundImage: post.authorPhotoUrl != null
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: post.authorPhotoUrl == null
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
                ),
                title: Text(
                  post.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: themeProvider.textColor,
                  ),
                ),
                subtitle: Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: UserDetailsScreen(userId: post.authorId)),
                  );
                },
              ),
              if (post.caption != null && post.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    post.caption!,
                    style: TextStyle(color: themeProvider.textColor),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (post.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    post.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}', style: TextStyle(color: themeProvider.secondaryTextColor)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 16, color: themeProvider.secondaryTextColor),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}', style: TextStyle(color: themeProvider.secondaryTextColor)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsTab(ThemeProvider themeProvider) {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_outlined,
        message: 'Search for events',
        themeProvider: themeProvider,
      );
    }

    if (_events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy,
        message: 'No events found',
        themeProvider: themeProvider,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.eventDate.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _getMonthName(event.eventDate.month),
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              event.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            subtitle: Text(
              event.location,
              style: TextStyle(color: themeProvider.secondaryTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.chevron_right, color: themeProvider.secondaryTextColor),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: EventDetailsScreen(event: event)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required ThemeProvider themeProvider,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: themeProvider.secondaryTextColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.secondaryTextColor,
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

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
