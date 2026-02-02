import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/job_model.dart';

// Custom colors
const Color _backgroundColor = Color(0xFFEBE3E3);
const Color _foregroundColor = Colors.black87;
const Color _accentColor = Color(0xFF8B77AA);

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to post a job'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user display name from Firestore
      final userData = await _firestoreService.getUser(user.uid);
      final authorName = userData?.displayName ?? user.displayName ?? 'Anonymous';
      final authorPhotoUrl = userData?.photoUrl ?? user.photoURL;

      final job = JobModel(
        id: '',
        authorId: user.uid,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        salary: _salaryController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createJob(job);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _foregroundColor, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Post a Job',
          style: TextStyle(
            color: _foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title
                _buildLabel('Job Title'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g., Software Engineer',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Job title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Company
                _buildLabel('Company'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _companyController,
                  hint: 'e.g., Tech Corp',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Company name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Location
                _buildLabel('Location'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hint: 'e.g., Islamabad, Pakistan',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Salary
                _buildLabel('Salary'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _salaryController,
                  hint: 'e.g., 50,000 PKR/month',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Salary is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description
                _buildLabel('Description (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe the job requirements and responsibilities...',
                  maxLines: 5,
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      disabledBackgroundColor: _accentColor.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'POST JOB',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _foregroundColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: _foregroundColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _foregroundColor.withValues(alpha: 0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
