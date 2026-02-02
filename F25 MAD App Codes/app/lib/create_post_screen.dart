import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  double _uploadProgress = 0;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFCBB8A1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final fileName =
          'posts/${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      
      // Get the storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(fileName);

      // Read file as bytes for more reliable upload
      final bytes = await _selectedImage!.readAsBytes();

      // Add metadata for proper image handling
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId ?? ''},
      );

      final uploadTask = fileRef.putData(bytes, metadata);

      uploadTask.snapshotEvents.listen((event) {
        if (mounted) {
          setState(() {
            _uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        }
      });

      final snapshot = await uploadTask;
      
      // Verify upload was successful
      if (snapshot.state == TaskState.success) {
        return await fileRef.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Post image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();

    if (caption.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a caption or image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to create a post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      final post = PostModel(
        id: '',
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        authorPhotoUrl: user.photoURL,
        imageUrl: imageUrl,
        caption: caption.isNotEmpty ? caption : null,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4A5A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB4A5A5),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _createPost,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: FirebaseAuth
                                .instance.currentUser?.photoURL !=
                            null
                        ? NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL!)
                        : null,
                    child: FirebaseAuth.instance.currentUser?.photoURL == null
                        ? const Icon(Icons.person, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? 'You',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Caption input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _captionController,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Image preview
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Upload progress
              if (_isLoading && _uploadProgress > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFCBB8A1)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading... ${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Add image button
              if (_selectedImage == null)
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
