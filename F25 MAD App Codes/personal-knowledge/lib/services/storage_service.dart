import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service class for Firebase Storage operations
/// Handles file uploads, downloads, and deletions
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============ UPLOAD OPERATIONS ============

  /// Upload a file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required String storagePath,
    String? contentType,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      
      // Set metadata if provided
      SettableMetadata? uploadMetadata;
      if (contentType != null || metadata != null) {
        uploadMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        );
      }

      // Upload the file
      final uploadTask = ref.putFile(file, uploadMetadata);

      // Monitor upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get and return the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload raw bytes to Firebase Storage
  /// Useful for uploading data that's already in memory
  Future<String> uploadBytes({
    required List<int> bytes,
    required String storagePath,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      
      SettableMetadata? uploadMetadata;
      if (contentType != null || metadata != null) {
        uploadMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        );
      }

      final uploadTask = await ref.putData(
        bytes as dynamic,
        uploadMetadata,
      );
      
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload bytes: $e');
    }
  }

  // ============ DOWNLOAD OPERATIONS ============

  /// Get the download URL for a file
  Future<String> getDownloadUrl({required String storagePath}) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Download a file to local storage
  Future<File> downloadFile({
    required String storagePath,
    required String localFilePath,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final file = File(localFilePath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Get file bytes directly
  Future<List<int>?> getFileBytes({
    required String storagePath,
    int maxSize = 10 * 1024 * 1024, // 10MB default
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getData(maxSize);
    } catch (e) {
      throw Exception('Failed to get file bytes: $e');
    }
  }

  // ============ METADATA OPERATIONS ============

  /// Get file metadata
  Future<FullMetadata> getMetadata({required String storagePath}) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get metadata: $e');
    }
  }

  /// Update file metadata
  Future<FullMetadata> updateMetadata({
    required String storagePath,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      );
      return await ref.updateMetadata(metadata);
    } catch (e) {
      throw Exception('Failed to update metadata: $e');
    }
  }

  // ============ DELETE OPERATIONS ============

  /// Delete a file from Firebase Storage
  Future<void> deleteFile({required String storagePath}) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles({required List<String> storagePaths}) async {
    try {
      for (final path in storagePaths) {
        await deleteFile(storagePath: path);
      }
    } catch (e) {
      throw Exception('Failed to delete files: $e');
    }
  }

  // ============ LIST OPERATIONS ============

  /// List all files in a directory
  Future<List<Reference>> listFiles({
    required String directoryPath,
    int? maxResults,
  }) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// List all subdirectories in a directory
  Future<List<Reference>> listDirectories({required String directoryPath}) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final result = await ref.listAll();
      return result.prefixes;
    } catch (e) {
      throw Exception('Failed to list directories: $e');
    }
  }

  // ============ HELPER METHODS ============

  /// Generate a unique filename with timestamp
  String generateUniqueFileName({
    required String originalFileName,
    String? userId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    final nameWithoutExt = originalFileName.split('.').first;
    
    if (userId != null) {
      return '${userId}_${nameWithoutExt}_$timestamp.$extension';
    }
    return '${nameWithoutExt}_$timestamp.$extension';
  }

  /// Get storage path for user files
  String getUserStoragePath({
    required String userId,
    required String fileName,
    String subfolder = 'files',
  }) {
    return 'users/$userId/$subfolder/$fileName';
  }
}
