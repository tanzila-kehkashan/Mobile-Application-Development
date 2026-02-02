import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'storage_service.dart';
import 'firestore_service.dart';

/// Service class for managing user profile operations
/// Handles profile picture uploads and user data management
class UserProfileService {
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _usersCollection = 'users';

  // ============ PROFILE PICTURE OPERATIONS ============

  /// Upload profile picture to Firebase Storage and update Firestore
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture({
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename for profile picture
      final fileName = _storageService.generateUniqueFileName(
        originalFileName: 'profile_picture.jpg',
        userId: user.uid,
      );

      // Get storage path for profile pictures
      final storagePath = _storageService.getUserStoragePath(
        userId: user.uid,
        fileName: fileName,
        subfolder: 'profile_pictures',
      );

      // Upload image to Firebase Storage
      final downloadUrl = await _storageService.uploadFile(
        file: imageFile,
        storagePath: storagePath,
        contentType: 'image/jpeg',
        onProgress: onProgress,
      );

      // Update user profile in Firestore
      await updateUserProfile(profilePictureUrl: downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete current profile picture
  Future<void> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current profile data
      final profile = await getUserProfile();
      final profilePictureUrl = profile?['profilePictureUrl'] as String?;

      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        // Extract storage path from URL (simplified approach)
        // In production, store the storage path separately in Firestore
        
        // Update Firestore to remove profile picture URL
        await updateUserProfile(profilePictureUrl: '');
      }
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  // ============ USER PROFILE OPERATIONS ============

  /// Get user profile data from Firestore
  /// Returns null if profile doesn't exist
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      return await _firestoreService.getDocument(
        collectionPath: _usersCollection,
        documentId: user.uid,
      );
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Stream user profile data for real-time updates
  Stream<Map<String, dynamic>?> streamUserProfile() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      return _firestoreService.streamDocument(
        collectionPath: _usersCollection,
        documentId: user.uid,
      );
    } catch (e) {
      throw Exception('Failed to stream user profile: $e');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (displayName != null) data['displayName'] = displayName;
      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
      if (additionalData != null) data.addAll(additionalData);

      // Check if profile exists
      final profile = await getUserProfile();
      
      if (profile == null) {
        // Create new profile
        data['createdAt'] = DateTime.now().toIso8601String();
        data['userId'] = user.uid;
        data['email'] = user.email ?? '';
        
        await _firestoreService.setDocument(
          collectionPath: _usersCollection,
          documentId: user.uid,
          data: data,
        );
      } else {
        // Update existing profile
        await _firestoreService.updateDocument(
          collectionPath: _usersCollection,
          documentId: user.uid,
          data: data,
        );
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Create initial user profile (call this after user registration)
  Future<void> createUserProfile({
    required String email,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'userId': user.uid,
        'email': email,
        'displayName': displayName ?? '',
        'phoneNumber': phoneNumber ?? '',
        'profilePictureUrl': '',
        'hiddenNotesPin': '', // Initialize with empty PIN
        'pinSetAt': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestoreService.setDocument(
        collectionPath: _usersCollection,
        documentId: user.uid,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // ============ PIN MANAGEMENT OPERATIONS ============

  /// Set or update the hidden notes PIN for the current user
  Future<void> setHiddenNotesPin({required String hashedPin}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestoreService.updateDocument(
        collectionPath: _usersCollection,
        documentId: user.uid,
        data: {
          'hiddenNotesPin': hashedPin,
          'pinSetAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // If document doesn't exist, create it with PIN
      final user = _auth.currentUser;
      if (user != null) {
        await _firestoreService.setDocument(
          collectionPath: _usersCollection,
          documentId: user.uid,
          data: {
            'userId': user.uid,
            'email': user.email ?? '',
            'hiddenNotesPin': hashedPin,
            'pinSetAt': DateTime.now().toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          merge: true,
        );
      }
    }
  }

  /// Get the hashed PIN for the current user
  /// Returns null if no PIN is set
  Future<String?> getHiddenNotesPin() async {
    try {
      final profile = await getUserProfile();
      if (profile == null) return null;
      
      final pin = profile['hiddenNotesPin'] as String?;
      return (pin != null && pin.isNotEmpty) ? pin : null;
    } catch (e) {
      throw Exception('Failed to get PIN: $e');
    }
  }

  /// Check if the user has set a PIN
  Future<bool> hasHiddenNotesPin() async {
    try {
      final pin = await getHiddenNotesPin();
      return pin != null;
    } catch (e) {
      return false;
    }
  }

  /// Remove the hidden notes PIN
  Future<void> removeHiddenNotesPin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestoreService.updateDocument(
        collectionPath: _usersCollection,
        documentId: user.uid,
        data: {
          'hiddenNotesPin': '',
          'pinSetAt': '',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to remove PIN: $e');
    }
  }

  /// Get the date when PIN was set
  Future<DateTime?> getPinSetDate() async {
    try {
      final profile = await getUserProfile();
      if (profile == null) return null;
      
      final pinSetAt = profile['pinSetAt'] as String?;
      if (pinSetAt == null || pinSetAt.isEmpty) return null;
      
      return DateTime.tryParse(pinSetAt);
    } catch (e) {
      return null;
    }
  }
}
