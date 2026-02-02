import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/job_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'package:nexus/utils/animations.dart';
import 'notification_screen.dart';
import 'job_details_screen.dart';
import 'create_job_screen.dart';

// Custom colors derived from the Figma design series
const Color _backgroundColor = Color(0xFFEBE3E3); // Light Taupe/Mauve
const Color _cardColor = Color(0xFFDCDCDC); // Soft Grey for the job cards
const Color _foregroundColor = Colors.black87; // Dark text/icon color

class JobsFeedScreen extends StatefulWidget {
  const JobsFeedScreen({super.key});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();
}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Helper widget for a single job card
  Widget _buildJobCard(BuildContext context, JobModel job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlidePageRoute(page: JobDetailsScreen(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Job details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User and time posted
                  Row(
                    children: [
                      Text(
                        job.authorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _foregroundColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        job.timeAgo,
                        style: TextStyle(
                          fontSize: 14,
                          color: _foregroundColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Job Title
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Location and Salary
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Icon and Text
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: _foregroundColor),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _foregroundColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Salary Icon and Text
                      const Icon(Icons.monetization_on_outlined,
                          size: 18, color: _foregroundColor),
                      const SizedBox(width: 4),
                      Text(
                        job.salary,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Arrow (Right side)
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: _foregroundColor,
                size: 28,
              ),
            ),
          ],
        ),
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
          icon: const Icon(Icons.arrow_back, color: _foregroundColor, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Jobs Feed',
          style: TextStyle(
            color: _foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
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
      body: StreamBuilder<List<JobModel>>(
        stream: _firestoreService.jobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: _foregroundColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No jobs posted yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to post a job!',
                    style: TextStyle(
                      color: _foregroundColor.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return AnimatedListItem(
                index: index,
                child: _buildJobCard(context, jobs[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: ScaleAnimation(
        delay: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.push(
                context,
                SlideUpPageRoute(page: const CreateJobScreen()),
              );
            }
          },
          backgroundColor: const Color(0xFF8B77AA),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
