import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update user profile data
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    List<String>? interests,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (interests != null) updates['interests'] = interests;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update user name
  Future<void> updateUserName(String userId, String name) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
      });
    } catch (e) {
      print('Error updating user name: $e');
      rethrow;
    }
  }

  // Update user bio
  Future<void> updateUserBio(String userId, String bio) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'bio': bio,
      });
    } catch (e) {
      print('Error updating user bio: $e');
      rethrow;
    }
  }

  // Update user interests
  Future<void> updateUserInterests(String userId, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'interests': interests,
      });
    } catch (e) {
      print('Error updating user interests: $e');
      rethrow;
    }
  }

  // Add interest to user
  Future<void> addInterest(String userId, String interest) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'interests': FieldValue.arrayUnion([interest]),
      });
    } catch (e) {
      print('Error adding interest: $e');
      rethrow;
    }
  }

  // Remove interest from user
  Future<void> removeInterest(String userId, String interest) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'interests': FieldValue. arrayRemove([interest]),
      });
    } catch (e) {
      print('Error removing interest: $e');
      rethrow;
    }
  }
}