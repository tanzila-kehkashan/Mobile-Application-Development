import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling image picking and storage
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<File?> pickFromGallery({int maxWidth = 800, int maxHeight = 800, int quality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickFromCamera({int maxWidth = 800, int maxHeight = 800, int quality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Save profile image to app directory
  Future<String?> saveProfileImage(File imageFile, String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${directory.path}/profile_images');
      
      // Create directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }
      
      // Generate unique filename
      final extension = path.extension(imageFile.path);
      final fileName = 'profile_$userId$extension';
      final savedPath = '${profileDir.path}/$fileName';
      
      // Delete old profile image if exists
      final existingFile = File(savedPath);
      if (await existingFile.exists()) {
        await existingFile.delete();
      }
      
      // Copy image to app directory
      await imageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return null;
    }
  }

  /// Delete profile image
  Future<bool> deleteProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      return false;
    }
  }

  /// Check if image file exists
  Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    final file = File(imagePath);
    return await file.exists();
  }

  /// Get file size in MB
  Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}

/// Dialog for selecting image source
class ImagePickerDialog extends StatelessWidget {
  final bool hasExistingImage;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;
  final VoidCallback? onRemoveSelected;

  const ImagePickerDialog({
    super.key,
    this.hasExistingImage = false,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onRemoveSelected,
  });

  /// Show the dialog and return the selected source
  static Future<ImageSource?> show(BuildContext context, {bool hasExistingImage = false}) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF4A3D7E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        hasExistingImage: hasExistingImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3D7E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Photo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  onCameraSelected?.call();
                },
              ),
              _buildOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  onGallerySelected?.call();
                },
              ),
              if (hasExistingImage)
                _buildOption(
                  icon: Icons.delete_outline,
                  label: 'Remove',
                  onTap: () {
                    Navigator.pop(context);
                    onRemoveSelected?.call();
                  },
                  color: Colors.redAccent,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFFE8FF78)).withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? const Color(0xFFE8FF78),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for image source selection
class ImagePickerBottomSheet extends StatelessWidget {
  final bool hasExistingImage;

  const ImagePickerBottomSheet({
    super.key,
    this.hasExistingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (hasExistingImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                onTap: () => Navigator.pop(context, null),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
