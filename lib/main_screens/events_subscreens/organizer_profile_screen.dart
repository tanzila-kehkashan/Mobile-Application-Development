import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/events_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../explore_subscreens/side_drawer_screens/chat_screen.dart';
import 'event_details_screen.dart';

class OrganizerProfileScreen extends ConsumerStatefulWidget {
  final String organizerName;
  final String organizerId;

  const OrganizerProfileScreen({
    Key? key,
    required this.organizerName,
    this.organizerId = '',
  }) : super(key: key);

  @override
  ConsumerState<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends ConsumerState<OrganizerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isLoadingChat = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Start a chat with the organizer
  Future<void> _startChat() async {
    if (widget.organizerId.isEmpty) {
      _showSnackBar('Organizer information not available');
      return;
    }

    final currentUser = ref.read(authStateProvider). value;
    if (currentUser == null) {
      _showSnackBar('Please log in to start a chat');
      return;
    }

    if (currentUser.uid == widget.organizerId) {
      _showSnackBar('You cannot message yourself');
      return;
    }

    setState(() {
      _isLoadingChat = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);

      // Get organizer's name from user data
      final organizerData = await ref.read(userByIdFutureProvider(widget.organizerId). future);
      final organizerName = organizerData?['name'] ?? widget.organizerName;

      final currentUserName = currentUser.displayName ?? 'User';

      // Create or get existing chat room
      final chatId = await chatService.getOrCreateChatRoom(
        currentUser.uid,
        widget.organizerId,
        currentUserName,
        organizerName,
      );

      setState(() {
        _isLoadingChat = false;
      });

      // Navigate to chat screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: widget.organizerId,
              otherUserName: organizerName,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingChat = false;
      });
      _showSnackBar('Error starting chat: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5B4EFF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch organizer's user data if organizerId is provided
    final organizerDataAsync = widget.organizerId.isNotEmpty
        ? ref.watch(userByIdProvider(widget.organizerId))
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons. arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. more_vert, color: Colors. black87),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: organizerDataAsync == null
          ? _buildProfileWithoutData()
          : organizerDataAsync. when(
        data: (userData) => _buildProfileWithData(userData),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4EFF),
          ),
        ),
        error: (error, stack) => _buildProfileWithoutData(),
      ),
    );
  }

  Widget _buildProfileWithoutData() {
    // Fallback UI when no user data is available
    return Column(
      children: [
        _buildProfileHeader(
          name: widget.organizerName,
          following: 0,
          followers: 0,
          bio: '',
          interests: [],
        ),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab('No bio available'),
              _buildEventTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileWithData(Map<String, dynamic>? userData) {
    final name = userData?['name'] ?? widget.organizerName;
    final following = userData?['following'] ??  0;
    final followers = userData?['followers'] ?? 0;
    final bio = userData? ['bio'] ?? 'No bio available';
    final interests = List<String>.from(userData?['interests'] ?? []);

    return Column(
      children: [
        _buildProfileHeader(
          name: name,
          following: following,
          followers: followers,
          bio: bio,
          interests: interests,
        ),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(bio, interests: interests),
              _buildEventTab(),
              _buildReviewsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required int following,
    required int followers,
    required String bio,
    required List<String> interests,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: Border.all(
                color: const Color(0xFF5B4EFF),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 45,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(following. toString(), 'Following'),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.grey[300],
              ),
              _buildStatItem(followers.toString(), 'Followers'),
            ],
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                    });
                  },
                  icon: Icon(
                    _isFollowing ?  Icons.check : Icons.person_add_outlined,
                    size: 18,
                  ),
                  label: Text(_isFollowing ? 'Following' : 'Follow'),
                  style: ElevatedButton. styleFrom(
                    backgroundColor: const Color(0xFF5B4EFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoadingChat ? null : _startChat,
                  icon: _isLoadingChat
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF5B4EFF),
                    ),
                  )
                      : const Icon(Icons.message_outlined, size: 18),
                  label: Text(_isLoadingChat ? 'Loading...' : 'Messages'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B4EFF),
                    side: const BorderSide(
                      color: Color(0xFF5B4EFF),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets. symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]! ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF5B4EFF),
        unselectedLabelColor: Colors. grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: const Color(0xFF5B4EFF),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'ABOUT'),
          Tab(text: 'EVENT'),
          Tab(text: 'REVIEWS'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ABOUT TAB - Now displays real bio and interests
  Widget _buildAboutTab(String bio, {List<String> interests = const []}) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          bio,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        if (interests.isNotEmpty) ...[
    const SizedBox(height: 24),
    const Text(
    'Interests',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    const SizedBox(height: 12),
    Wrap(
    spacing: 8,
    runSpacing: 8,
    children: interests. map((interest) {
    return Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
    ),
    decoration: BoxDecoration(
    color: const Color(0xFF5B4EFF). withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
    color: const Color(0xFF5B4EFF). withOpacity(0.3),
    ),
    ),
    child: Text(
    interest,
    style: const TextStyle(
    fontSize: 14,
    color: Color(0xFF5B4EFF),
    fontWeight: FontWeight.w500,
    ),
    ),
    );
    }).toList(),
    ),
    ],
    ],
    ),
    );
  }

  // EVENT TAB - Using Riverpod
  Widget _buildEventTab() {
    // Only fetch events if organizerId is provided
    if (widget.organizerId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No events available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final eventsAsync = ref.watch(eventsByOrganizerProvider(widget.organizerId));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons. event_busy, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No events yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors. grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This organizer hasn\'t created any events',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events. length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index]);
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading events',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final backgroundColor = _getColorForCategory(event['category'] ?? 'Music');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: event['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Image
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius. horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.white. withOpacity(0.5),
                ),
              ),
            ),
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event['day']} ${event['month']}, ${event['startTime'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B4EFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['title'] ?? 'Event Title',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors. black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['location'] ?? 'Location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors. grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Color _getColorForCategory(String category) {
    switch (category. toLowerCase()) {
      case 'sports':
        return const Color(0xFFFF6B6B);
      case 'music':
        return const Color(0xFFFF9B57);
      case 'food':
        return const Color(0xFF4CAF50);
      case 'art':
        return const Color(0xFF9C27B0);
      case 'clubbing':
        return const Color(0xFF00D9A5);
      case 'theater':
        return const Color(0xFF5B4EFF);
      default:
        return Colors.pink[100]!;
    }
  }

  // REVIEWS TAB
  Widget _buildReviewsTab() {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'Adele Velingker',
        'rating': 5,
        'date': '10 Feb',
        'comment':
        'Cinema is the ultimate pervert art.  It doesn\'t give you what you desire - it tells you how to desire.',
        'avatar': Colors.orange,
      },
      {
        'name': 'Angelina Zolly',
        'rating': 4,
        'date': '9 Feb',
        'comment':
        'Cinema is the ultimate pervert art. It doesn\'t give you what you desire - it tells you how to desire.',
        'avatar': Colors.pink,
      },
      {
        'name': 'Zenfero Sales',
        'rating': 5,
        'date': '10 Feb',
        'comment': '',
        'avatar': Colors.blue,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => Divider(
        height: 32,
        color: Colors.grey[200],
      ),
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index]);
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: review['avatar'],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Name and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review['date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors. grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Rating Stars
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < review['rating'] ? Icons.star : Icons. star_border,
              color: const Color(0xFFFFB800),
              size: 18,
            );
          }),
        ),
        if (review['comment']. isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets. symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // Share action
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Report action
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: Colors.red),
              title: const Text('Block', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Block action
              },
            ),
          ],
        ),
      ),
    );
  }
}