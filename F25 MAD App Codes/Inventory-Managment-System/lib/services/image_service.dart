import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling image uploads to Firebase Storage
class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String?> uploadProductImage(XFile imageFile, String productId) async {
    if (currentUserId == null) {
      throw 'User not logged in';
    }

    try {
      // Create a unique file name
      final String fileName =
          'products/${currentUserId}/${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);

      // Read image as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': currentUserId!,
          'productId': productId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file
      final UploadTask uploadTask = ref.putData(imageBytes, metadata);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteProductImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw - image might already be deleted
    }
  }

  /// Upload image from bytes (for web)
  Future<String?> uploadImageBytes(
    Uint8List imageBytes,
    String productId,
  ) async {
    if (currentUserId == null) {
      throw 'User not logged in';
    }

    try {
      final String fileName =
          'products/${currentUserId}/${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': currentUserId!, 'productId': productId},
      );

      final UploadTask uploadTask = ref.putData(imageBytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload profile image from bytes
  Future<String?> uploadProfileImage(Uint8List imageBytes) async {
    if (currentUserId == null) {
      print('Upload failed: User not logged in');
      return null;
    }

    try {
      print('Starting profile image upload for user: $currentUserId');
      print('Image size: ${imageBytes.length} bytes');

      // Use a simpler path structure
      final String fileName = 'profile_images/$currentUserId.jpg';
      final Reference ref = _storage.ref().child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=300',
      );

      print('Uploading to: $fileName');

      // Upload with progress tracking
      final UploadTask uploadTask = ref.putData(imageBytes, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Profile image uploaded successfully: $downloadUrl');
        return downloadUrl;
      } else {
        print('Upload failed with state: ${snapshot.state}');
        return null;
      }
    } on FirebaseException catch (e) {
      print('Firebase error uploading profile image: ${e.code} - ${e.message}');
      // If permission denied, the Firebase Storage rules might need updating
      if (e.code == 'permission-denied' || e.code == 'unauthorized') {
        print(
          'PERMISSION ERROR: Please update Firebase Storage rules to allow write access',
        );
      }
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}

/// Global instance of ImageService
final imageService = ImageService();
