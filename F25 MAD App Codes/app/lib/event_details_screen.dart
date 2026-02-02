import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/models/event_model.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'menu_screen.dart';
import 'notification_screen.dart';

// Custom colors derived from the Figma design series
const Color _backgroundColor = Color(0xFFEBE3E3);
const Color _foregroundColor = Colors.black87;
const Color _headingColor = Color(0xFF8B77AA);

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isDeleting = false;

  bool get _isOwner {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && currentUserId == widget.event.organizerId;
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _firestoreService.deleteEvent(widget.event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailSection(String title, {bool isUnderlined = true}) {
    return Container(
      width: title.length * 10.5 + 20,
      decoration: BoxDecoration(
        border: isUnderlined
            ? const Border(
                bottom: BorderSide(
                  color: _headingColor,
                  width: 1.0,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _foregroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildValueText(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _foregroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: _foregroundColor, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              SlidePageRoute(page: const MenuScreen()),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Event',
          style: TextStyle(
            color: _foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (_isOwner)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              onPressed: _isDeleting ? null : _deleteEvent,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: _foregroundColor, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const NotificationScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, color: _foregroundColor, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: _foregroundColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Events Description Header
              const Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Text(
                  'Events Description',
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Event Title
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: _foregroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Department
              if (widget.event.department != null)
                Row(
                  children: [
                    const Icon(Icons.business, color: _headingColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.department!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _foregroundColor,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Image Display
              if (widget.event.imageUrl != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.event.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            color: _headingColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  color: _foregroundColor.withValues(alpha: 0.5)),
                              Text(
                                'Image failed to load',
                                style: TextStyle(
                                    color:
                                        _foregroundColor.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Featured Activities
              if (widget.event.featuredActivities.isNotEmpty) ...[
                const Text(
                  'Featured Activities',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.event.featuredActivities.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      activity,
                      style: TextStyle(
                        color: _foregroundColor.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Description
              if (widget.event.description != null &&
                  widget.event.description!.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(
                    color: _foregroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.event.description!,
                  style: TextStyle(
                    color: _foregroundColor.withValues(alpha: 0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

              // Date and Time Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Date'),
                        const SizedBox(height: 10.0),
                        _buildValueText(widget.event.formattedDate),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Time'),
                        const SizedBox(height: 10.0),
                        _buildValueText(
                          widget.event.endTime != null
                              ? '${widget.event.startTime} - ${widget.event.endTime}'
                              : '${widget.event.startTime} Onwards',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Location Detail
              _buildDetailSection('Location'),
              const SizedBox(height: 10),
              _buildValueText(widget.event.location),

              const SizedBox(height: 30),

              // Organized by
              _buildDetailSection('Organized by'),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: widget.event.organizerPhotoUrl != null
                        ? NetworkImage(widget.event.organizerPhotoUrl!)
                        : null,
                    child: widget.event.organizerPhotoUrl == null
                        ? const Icon(Icons.person, color: Colors.black54)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.event.organizerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _foregroundColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
