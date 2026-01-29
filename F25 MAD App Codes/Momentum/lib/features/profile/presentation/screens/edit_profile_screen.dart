import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/services/image_service.dart';
import 'package:momentum/core/utils/error_handler.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/features/profile/presentation/screens/settings_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  DateTime? _dateOfBirth;
  bool _useMetricUnits = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  File? _profileImage;
  String? _existingImagePath;
  final ImagePicker _picker = ImagePicker();
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final appState = AppStateProvider.of(context);
      final user = appState.localUserData;

      _nameController.text = appState.userName;
      _emailController.text = appState.userEmail;
      _weightController.text = user?.weight?.toStringAsFixed(0) ?? '';
      _heightController.text = user?.height?.toStringAsFixed(0) ?? '';
      _ageController.text = user?.age?.toString() ?? '';
      _dateOfBirth = user?.dateOfBirth;
      _useMetricUnits = user?.useMetricUnits ?? false;
      _existingImagePath = user?.profileImagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        if (mounted) {
          ErrorHandler.showSuccess(context, 'Photo selected! Save to apply changes.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, 'Error picking image: $e');
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF4A3D7E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_profileImage != null || _existingImagePath != null)
                    _buildImageSourceOption(
                      icon: Icons.delete,
                      label: 'Remove',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _profileImage = null;
                          _existingImagePath = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF201A3F),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color ?? Colors.white),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      final file = File(_existingImagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE8FF78),
              surface: Color(0xFF4A3D7E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        final today = DateTime.now();
        int age = today.year - picked.year;
        if (today.month < picked.month ||
            (today.month == picked.month && today.day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    final appState = AppStateProvider.of(context);
    
    // Save profile picture if changed
    String? newImagePath = _existingImagePath;
    if (_profileImage != null && appState.localUserData != null) {
      newImagePath = await _imageService.saveProfileImage(
        _profileImage!,
        appState.localUserData!.id,
      );
    } else if (_profileImage == null && _existingImagePath == null) {
      // User removed the photo
      newImagePath = null;
    }
    
    // Update profile picture path
    if (newImagePath != _existingImagePath) {
      await appState.updateProfilePicture(newImagePath);
    }
    
    // Update other profile info
    final success = await appState.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
      age: int.tryParse(_ageController.text),
      dateOfBirth: _dateOfBirth,
      useMetricUnits: _useMetricUnits,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ErrorHandler.showSuccess(context, 'Profile updated successfully!');
      Navigator.pop(context);
    } else {
      ErrorHandler.showError(context, 'Failed to update profile. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8FF78),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF4A3D7E),
                      backgroundImage: _getProfileImage(),
                      child: (_profileImage == null && _existingImagePath == null)
                          ? Text(
                              (_nameController.text.isNotEmpty 
                                  ? _nameController.text 
                                  : 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FF78),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF201A3F),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF201A3F),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showImagePickerOptions,
                child: const Text(
                  'Change Photo',
                  style: TextStyle(
                    color: Color(0xFFE8FF78),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildMeasurementField(
                label: 'Height',
                controller: _heightController,
                unit: _useMetricUnits ? 'cm' : 'in',
              ),
              const SizedBox(height: 16),
              _buildMeasurementField(
                label: 'Weight',
                controller: _weightController,
                unit: _useMetricUnits ? 'kg' : 'lbs',
              ),
              const SizedBox(height: 16),
              _buildUnitToggle(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8FF78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Color(0xFF201A3F),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF4A3D7E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Text('Birth Date', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3D7E),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.month}/${_dateOfBirth!.day}/${_dateOfBirth!.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: _dateOfBirth != null ? Colors.white : Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementField({
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3D7E),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Text(unit, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Text('Units', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3D7E),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useMetricUnits = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_useMetricUnits ? const Color(0xFFE8FF78) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Imperial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_useMetricUnits ? const Color(0xFF201A3F) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useMetricUnits = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _useMetricUnits ? const Color(0xFFE8FF78) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Metric',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _useMetricUnits ? const Color(0xFF201A3F) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
