import 'package:event_hub/main_screens/events_subscreens/ticket_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/events_provider.dart';
import 'organizer_profile_screen.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (eventData) {
          if (eventData == null) {
            return const Center(
              child: Text('Event not found'),
            );
          }

          return _buildEventDetails(eventData);
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5B4EFF),
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment. center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading event details',
                  style: TextStyle(color: Colors.red[400]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> event) {
    String formattedDate = 'Date not available';
    String formattedTime = 'Time not available';

    try {
      final dateTimestamp = event['date'] as Timestamp? ;
      if (dateTimestamp != null) {
        formattedDate = '${event['day']} ${event['month']}, ${event['year']}';
      }

      if (event['startTime'] != null && event['endTime'] != null) {
        formattedTime = '${event['startTime']} - ${event['endTime']}';
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return Stack(
      children: [
        // Scrollable Content
        CustomScrollView(
          slivers: [
            // Hero Image with App Bar
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: const Color(0xFF5B4EFF),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator. pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black. withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors. white. withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Event Details Content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendees and Invite Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Attendee Avatars
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: _buildAvatar(Colors.blue),
                                ),
                                Positioned(
                                  left: 20,
                                  child: _buildAvatar(Colors.pink),
                                ),
                                Positioned(
                                  left: 40,
                                  child: _buildAvatar(Colors.green),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${event['attendees'] ?? 20} Going',
                            style: const TextStyle(
                              color: Color(0xFF5B4EFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // Invite action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B4EFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Invite',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Event Title
                    Padding(
                      padding: const EdgeInsets. symmetric(horizontal: 20),
                      child: Text(
                        event['title'] ?? 'International Band\nMusic Concert',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors. black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Date & Time
                    _buildInfoTile(
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFF5B4EFF),
                      iconBgColor: const Color(0xFF5B4EFF). withOpacity(0.1),
                      title: formattedDate,
                      subtitle: formattedTime,
                    ),
                    const SizedBox(height: 16),
                    // Location
                    _buildInfoTile(
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF5B4EFF),
                      iconBgColor: const Color(0xFF5B4EFF).withOpacity(0.1),
                      title: event['location'] ??  'Gala Convention Center',
                      subtitle: event['address'] ?? '36 Guild Street London, UK',
                    ),
                    const SizedBox(height: 16),
                    // Organizer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.1),
                              borderRadius: BorderRadius. circular(12),
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['organizerName'] ?? 'Ashfak Sayem',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Organizer',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrganizerProfileScreen(
                                    organizerName: event['organizerName'] ?? 'Ashfak Sayem',
                                    organizerId: event['organizerId'] ?? '',
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5B4EFF),
                              side: const BorderSide(
                                color: Color(0xFF5B4EFF),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets. symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // About Event
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'About Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors. black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        event['description'] ??
                            'Enjoy your favorite dishe and a lovely your friends and family and have a great time.  Food from local food trucks will be available for purchase.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors. black54,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        ),
        // Floating Buy Ticket Button
        // Floating Buy Ticket Button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black. withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to booking screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookTicketScreen(event: event),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4EFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets. symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BUY TICKET ${event['price'] != null ? '\$${event['price']}' : '\$20'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}