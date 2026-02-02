import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/theme_provider.dart';
import 'package:nexus/models/job_model.dart';
import 'package:nexus/models/event_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'job_details_screen.dart';
import 'event_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<JobModel> _recentJobs = [];
  List<EventModel> _recentEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentItems();
  }

  Future<void> _loadRecentItems() async {
    try {
      final jobs = await _firestoreService.getRecentJobs(limit: 5);
      final events = await _firestoreService.getRecentEvents(limit: 5);
      
      if (mounted) {
        setState(() {
          _recentJobs = jobs;
          _recentEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Notifications',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRecentItems,
              child: _buildNotificationList(themeProvider),
            ),
    );
  }

  Widget _buildNotificationList(ThemeProvider themeProvider) {
    if (_recentJobs.isEmpty && _recentEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: themeProvider.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new jobs and events!',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent Jobs Section
        if (_recentJobs.isNotEmpty) ...[
          _buildSectionHeader('New Job Postings', Icons.work_outline, themeProvider),
          const SizedBox(height: 12),
          ..._recentJobs.asMap().entries.map((entry) => AnimatedListItem(
            index: entry.key,
            child: _buildJobNotificationCard(entry.value, themeProvider),
          )),
          const SizedBox(height: 24),
        ],
        
        // Recent Events Section
        if (_recentEvents.isNotEmpty) ...[
          _buildSectionHeader('Upcoming Events', Icons.event_outlined, themeProvider),
          const SizedBox(height: 12),
          ..._recentEvents.asMap().entries.map((entry) => AnimatedListItem(
            index: entry.key + _recentJobs.length,
            child: _buildEventNotificationCard(entry.value, themeProvider),
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(icon, size: 20, color: themeProvider.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildJobNotificationCard(JobModel job, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(page: JobDetailsScreen(job: job)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work,
                    color: themeProvider.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(job.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: themeProvider.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventNotificationCard(EventModel event, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              SlidePageRoute(page: EventDetailsScreen(event: event)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeAgo(event.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: themeProvider.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
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
}
