import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a job listing
class JobModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  /// Create JobModel from Firestore document
  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      authorPhotoUrl: map['authorPhotoUrl'],
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert JobModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Format time ago for display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
