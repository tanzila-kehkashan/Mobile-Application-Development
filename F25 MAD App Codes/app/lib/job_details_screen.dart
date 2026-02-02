import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/models/job_model.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'menu_screen.dart';
import 'notification_screen.dart';

// Custom colors derived from the Figma design series
const Color _backgroundColor = Color(0xFFEBE3E3); // Light Taupe/Mauve
const Color _foregroundColor = Colors.black87; // Dark text/icon color
const Color _headingColor = Color(0xFF8B77AA); // Purple for headings

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isDeleting = false;

  bool get _isOwner {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && currentUserId == widget.job.authorId;
  }

  Future<void> _deleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job posting? This action cannot be undone.'),
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
      await _firestoreService.deleteJob(widget.job.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job deleted successfully'),
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
            content: Text('Error deleting job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper widget to build the detail line with an underline
  Widget _buildDetailSection(String title, {bool isUnderlined = true}) {
    double widthFactor = title.length * 10.5 + 20;

    return Container(
      width: widthFactor,
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
          'Job Details',
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
              onPressed: _isDeleting ? null : _deleteJob,
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

              // Job Description Header
              const Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Text(
                  'Job Description',
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Job Title
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  widget.job.title,
                  style: const TextStyle(
                    color: _foregroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Company Name
              Row(
                children: [
                  const Icon(Icons.business, color: _headingColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.job.company,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _foregroundColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Image Display
              if (widget.job.imageUrl != null)
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
                      widget.job.imageUrl!,
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
                                  color: _foregroundColor.withValues(alpha: 0.5),
                                  size: 40),
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

              // Description
              if (widget.job.description != null && widget.job.description!.isNotEmpty) ...[
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
                  widget.job.description!,
                  style: TextStyle(
                    color: _foregroundColor.withValues(alpha: 0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Location and Salary Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Location'),
                        const SizedBox(height: 10.0),
                        _buildValueText(widget.job.location),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Salary'),
                        const SizedBox(height: 10.0),
                        _buildValueText(widget.job.salary),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Posted by
              _buildDetailSection('Posted by'),
              const SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: widget.job.authorPhotoUrl != null
                        ? NetworkImage(widget.job.authorPhotoUrl!)
                        : null,
                    child: widget.job.authorPhotoUrl == null
                        ? const Icon(Icons.person, color: Colors.black54)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.authorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _foregroundColor,
                        ),
                      ),
                      Text(
                        widget.job.timeAgo,
                        style: TextStyle(
                          fontSize: 14,
                          color: _foregroundColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
