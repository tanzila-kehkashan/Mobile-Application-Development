import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a user in the app
class UserModel {
  final String uid;
  final String email;
  final String? username;
  final String? displayName;
  final String? photoUrl;
  final String? university;
  final String? major;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.username,
    this.displayName,
    this.photoUrl,
    this.university,
    this.major,
    this.bio,
    this.followers = const [],
    this.following = const [],
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      username: map['username'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      university: map['university'],
      major: map['major'],
      bio: map['bio'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'university': university,
      'major': major,
      'bio': bio,
      'followers': followers,
      'following': following,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? username,
    String? displayName,
    String? photoUrl,
    String? university,
    String? major,
    String? bio,
    List<String>? followers,
    List<String>? following,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      university: university ?? this.university,
      major: major ?? this.major,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
