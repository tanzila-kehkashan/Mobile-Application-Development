import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/event_model.dart';

// Custom colors
const Color _backgroundColor = Color(0xFFEBE3E3);
const Color _foregroundColor = Colors.black87;
const Color _accentColor = Color(0xFF8B77AA);

class CreateEventScreen extends StatefulWidget {
  final DateTime initialDate;

  const CreateEventScreen({super.key, required this.initialDate});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _startTimeController.text = '9:00 AM';
    _endTimeController.text = '5:00 PM';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _accentColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _foregroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to create an event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = await _firestoreService.getUser(user.uid);
      final organizerName = userData?.displayName ?? user.displayName ?? 'Anonymous';
      final organizerPhotoUrl = userData?.photoUrl ?? user.photoURL;

      final event = EventModel(
        id: '',
        organizerId: user.uid,
        organizerName: organizerName,
        organizerPhotoUrl: organizerPhotoUrl,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        eventDate: _selectedDate,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim().isNotEmpty 
            ? _endTimeController.text.trim() 
            : null,
        department: _departmentController.text.trim().isNotEmpty 
            ? _departmentController.text.trim() 
            : null,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createEvent(event);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
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
          'Create Event',
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
                // Event Title
                _buildLabel('Event Title'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'e.g., Winter Sports Meet',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Date Picker
                _buildLabel('Event Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            color: _foregroundColor,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: _accentColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Time'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _startTimeController,
                            hint: '9:00 AM',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Time'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _endTimeController,
                            hint: '5:00 PM',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Location
                _buildLabel('Location'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hint: 'e.g., Sports Ground',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Department
                _buildLabel('Department (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _departmentController,
                  hint: 'e.g., Department of Computer Science',
                ),

                const SizedBox(height: 20),

                // Description
                _buildLabel('Description (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Describe the event details...',
                  maxLines: 4,
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
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
                            'CREATE EVENT',
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
    _locationController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
