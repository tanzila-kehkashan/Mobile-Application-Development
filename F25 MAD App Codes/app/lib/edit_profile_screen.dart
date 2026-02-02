import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/services/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();

  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _nameController.text = user.displayName ?? '';
    _currentPhotoUrl = user.photoURL;

    // Load additional data from Firestore
    final userData = await _firestoreService.getUser(user.uid);
    if (userData != null && mounted) {
      setState(() {
        _bioController.text = userData.bio ?? '';
        _universityController.text = userData.university ?? '';
        _majorController.text = userData.major ?? '';
        _currentPhotoUrl = userData.photoUrl ?? user.photoURL;
        _isInitialized = true;
      });
    } else {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
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

  Future<String?> _uploadProfileImage() async {
    if (_selectedImage == null) return _currentPhotoUrl;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Use a unique filename with timestamp to avoid caching issues
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profiles/${userId}_$timestamp.jpg';
      
      // Get the storage reference using the bucket from Firebase options
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(fileName);

      // Read file as bytes for more reliable upload
      final bytes = await _selectedImage!.readAsBytes();

      // Add metadata for proper image handling
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId},
      );

      // Upload using putData which is more reliable
      final uploadTask = fileRef.putData(bytes, metadata);
      final snapshot = await uploadTask;
      
      // Verify upload was successful
      if (snapshot.state == TaskState.success) {
        return await fileRef.getDownloadURL();
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Profile image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _currentPhotoUrl;
      if (_selectedImage != null) {
        photoUrl = await _uploadProfileImage();
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(_nameController.text.trim());
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore profile
      await _firestoreService.updateUser(user.uid, {
        'displayName': _nameController.text.trim(),
        'photoUrl': photoUrl,
        'bio': _bioController.text.trim(),
        'university': _universityController.text.trim(),
        'major': _majorController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate changes
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.secondaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.secondaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(themeProvider.textColor),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: !_isInitialized
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: themeProvider.cardColor,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_currentPhotoUrl != null
                                    ? NetworkImage(_currentPhotoUrl!)
                                        as ImageProvider
                                    : null),
                            child: _selectedImage == null &&
                                    _currentPhotoUrl == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Display Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bio field
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell us about yourself',
                      icon: Icons.info_outline,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // University field
                    _buildTextField(
                      controller: _universityController,
                      label: 'University',
                      hint: 'Enter your university',
                      icon: Icons.school_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Major field
                    _buildTextField(
                      controller: _majorController,
                      label: 'Major',
                      hint: 'Enter your major/field of study',
                      icon: Icons.book_outlined,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }
}
