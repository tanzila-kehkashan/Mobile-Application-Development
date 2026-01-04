import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/events_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';

import '../widgets/search_bar.dart';
import 'add_events_screens.dart';
import 'events_subscreens/event_details_screen.dart';
import 'events_subscreens/explore_events_screen.dart';
import 'explore_subscreens/notifications_screen.dart';
import 'explore_subscreens/side_drawer.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<CategoryItem> _categories = [
    CategoryItem('All', const Color(0xFF5B4EFF), Icons.grid_view),
    CategoryItem('Sports', const Color(0xFFFF6B6B), Icons.sports_soccer),
    CategoryItem('Music', const Color(0xFFFF9B57), Icons.music_note),
    CategoryItem('Food', const Color(0xFF4CAF50), Icons.restaurant),
    CategoryItem('Art', const Color(0xFF9C27B0), Icons.palette),
  ];

  @override
  void dispose() {
    _searchController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final nearbyEventsAsync = ref.watch(nearbyEventsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B4EFF), Color(0xFF4E7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () {
                            _scaffoldKey. currentState?.openDrawer();
                          },
                        ),
                        Text('Event Hub', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors. white, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                            // Show badge if unread notifications exist
                            if (user != null)
                              Consumer(
                                builder: (context, ref, child) {
                                  final notificationsAsync = ref.watch(userNotificationsProvider(user.uid));
                                  return notificationsAsync.when(
                                    data: (notifications) {
                                      final unreadCount = notifications.where((n) => !n.isRead).length;
                                      if (unreadCount == 0) return const SizedBox.shrink();
                                      
                                      return Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unreadCount > 99 ? '99+' : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    SearchBarWidget(hintText: 'Search... '),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upcoming Events Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // See all action
                          },
                          child: Row(
                            children: const [
                              Text(
                                'See All',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Upcoming Events List
                    upcomingEventsAsync.when(
                      data: (events) {
                        if (events.isEmpty) {
                          return Container(
                            height: 240,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy,
                                    size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(height: 12),
                                Text(
                                  'No upcoming events',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return _buildEventCard(event);
                            },
                          ),
                        );
                      },
                      loading: () => Container(
                        height: 240,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Color(0xFF5B4EFF),
                        ),
                      ),
                      error: (error, stack) => Container(
                        height: 240,
                        alignment: Alignment.center,
                        child: Text(
                          'Error loading events',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EventsListScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4EFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius. circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'EXPLORE EVENTS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Nearby You Section
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       'Nearby You',
                    //       style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {
                    //         // See all action
                    //       },
                    //       child: Row(
                    //         children: const [
                    //           Text(
                    //             'See All',
                    //             style: TextStyle(
                    //               color: Colors.grey,
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //           SizedBox(width: 4),
                    //           Icon(Icons. arrow_forward_ios,
                    //               color: Colors.grey, size: 12),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),
                    // // Nearby Events
                    // nearbyEventsAsync. when(
                    //   data: (events) {
                    //     if (events.isEmpty) {
                    //       return Container(
                    //         padding: const EdgeInsets.all(32),
                    //         alignment: Alignment.center,
                    //         child: Column(
                    //           children: [
                    //             Icon(Icons.location_off,
                    //                 size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    //             const SizedBox(height: 12),
                    //             Text(
                    //               'No nearby events found',
                    //               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //                 fontSize: 16,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     }
                    //     return Column(
                    //       children: events. take(3).map((event) {
                    //         return _buildNearbyEventCard(event);
                    //       }).toList(),
                    //     );
                    //   },
                    //   loading: () => const Center(
                    //     child: Padding(
                    //       padding: EdgeInsets.all(32),
                    //       child: CircularProgressIndicator(
                    //         color: Color(0xFF5B4EFF),
                    //       ),
                    //     ),
                    //   ),
                    //   error: (error, stack) => Center(
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(32),
                    //       child: Text(
                    //         'Error loading nearby events',
                    //         style: TextStyle(color: Colors.red[400]),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEventScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF5B4EFF),
        child: const Icon(Icons.add, color: Colors.white),
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
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius. circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image/Placeholder
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Colors. white. withOpacity(0.5),
                    ),
                  ),
                  // Date Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius. circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event['day'] ?? '10',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5757),
                            ),
                          ),
                          Text(
                            (event['month'] ?? 'JUNE'). substring(0, 3). toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF5757),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bookmark
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: Color(0xFFFF5757),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Event Title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Attendee Avatars
                      SizedBox(
                        width: 60,
                        height: 24,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _buildSmallAvatar(Colors.blue),
                            ),
                            Positioned(
                              left: 16,
                              child: _buildSmallAvatar(Colors.pink),
                            ),
                            Positioned(
                              left: 32,
                              child: _buildSmallAvatar(Colors.green),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${event['attendees'] ?? 20} Going',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5B4EFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors. grey),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyEventCard(Map<String, dynamic> event) {
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
          color: Theme.of(context).cardColor,
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
                  color: Colors. white.withOpacity(0.5),
                ),
              ),
            ),
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment. start,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
                            event['address'] ?? 'Address',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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

  Widget _buildSmallAvatar(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 12),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
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
}

class CategoryItem {
  final String name;
  final Color color;
  final IconData icon;

  CategoryItem(this.name, this.color, this.icon);
}