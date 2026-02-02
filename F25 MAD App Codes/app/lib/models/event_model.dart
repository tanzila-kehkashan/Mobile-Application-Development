import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an event
class EventModel {
  final String id;
  final String organizerId;
  final String organizerName;
  final String? organizerPhotoUrl;
  final String title;
  final String? description;
  final String location;
  final DateTime eventDate;
  final String startTime;
  final String? endTime;
  final String? department;
  final String? imageUrl;
  final List<String> featuredActivities;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    this.organizerPhotoUrl,
    required this.title,
    this.description,
    required this.location,
    required this.eventDate,
    required this.startTime,
    this.endTime,
    this.department,
    this.imageUrl,
    this.featuredActivities = const [],
    required this.createdAt,
  });

  /// Create EventModel from Firestore document
  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? 'Unknown',
      organizerPhotoUrl: map['organizerPhotoUrl'],
      title: map['title'] ?? '',
      description: map['description'],
      location: map['location'] ?? '',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'],
      department: map['department'],
      imageUrl: map['imageUrl'],
      featuredActivities: List<String>.from(map['featuredActivities'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert EventModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerPhotoUrl': organizerPhotoUrl,
      'title': title,
      'description': description,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'startTime': startTime,
      'endTime': endTime,
      'department': department,
      'imageUrl': imageUrl,
      'featuredActivities': featuredActivities,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Format date for display
  String get formattedDate {
    return '${eventDate.day}/${eventDate.month}/${eventDate.year}';
  }

  /// Check if event is on a specific date
  bool isOnDate(DateTime date) {
    return eventDate.year == date.year &&
        eventDate.month == date.month &&
        eventDate.day == date.day;
  }
}
