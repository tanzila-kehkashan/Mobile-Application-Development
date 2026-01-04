// Modified: Add optional eventId & eventData to support editing existing events.
// On submit, if eventId is provided we update instead of creating a new document.
// Prefills fields when eventData is provided.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_hub/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../services/events_service.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? eventData;

  const AddEventScreen({Key? key, this.eventId, this.eventData}) : super(key: key);

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCategory = 'Music';
  bool _isLoading = false;

  final List<String> _categories = [
    'Music',
    'Sports',
    'Food',
    'Art',
    'Clubbing',
    'Theater',
    'Conference',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    final ed = widget.eventData;
    if (ed == null) return;

    _titleController.text = ed['title'] ?? '';
    _descriptionController.text = ed['description'] ?? '';
    _locationController.text = ed['location'] ?? '';
    _addressController.text = ed['address'] ?? '';
    _priceController.text = (ed['price'] != null) ? ed['price'].toString() : '';
    _attendeesController.text = (ed['attendees'] != null) ? ed['attendees'].toString() : '';
    _selectedCategory = ed['category'] ?? 'Music';

    // Date
    try {
      final dateField = ed['date'];
      if (dateField is Timestamp) {
        _selectedDate = dateField.toDate();
      } else if (dateField is DateTime) {
        _selectedDate = dateField;
      }
    } catch (_) {}

    // startTime and endTime (strings like '4:00PM')
    _startTime = _tryParseTimeOfDay(ed['startTime'] as String?);
    _endTime = _tryParseTimeOfDay(ed['endTime'] as String?);
  }

  TimeOfDay? _tryParseTimeOfDay(String? s) {
    if (s == null) return null;
    try {
      // Normalize like '4:00PM' or '04:00 PM'
      final cleaned = s.replaceAll(' ', '').toUpperCase();
      final match = RegExp(r'^(\d{1,2}):(\d{2})(AM|PM)$').firstMatch(cleaned);
      if (match != null) {
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        final period = match.group(3)!;
        int hour = h % 12;
        if (period == 'PM') hour += 12;
        return TimeOfDay(hour: hour, minute: m);
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4EFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4EFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4EFF),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute$period';
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showSnackBar('Please select an event date', isError: true);
      return;
    }

    if (_startTime == null) {
      _showSnackBar('Please select start time', isError: true);
      return;
    }

    if (_endTime == null) {
      _showSnackBar('Please select end time', isError: true);
      return;
    }

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      _showSnackBar('You must be signed in to create or edit an event', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time for the stored 'date' field (we store start date/time)
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final Map<String, dynamic> eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'date': Timestamp.fromDate(eventDateTime),
        'day': _selectedDate!.day.toString(),
        'month': DateFormat('MMMM').format(_selectedDate!),
        'year': _selectedDate!.year.toString(),
        'startTime': _formatTimeOfDay(_startTime!),
        'endTime': _formatTimeOfDay(_endTime!),
        'organizerId': currentUser.uid,
        'organizerName': currentUser.displayName ?? 'Unknown',
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategory,
        // keep existing imageUrl if editing and not changing images
        'imageUrl': widget.eventData != null ? (widget.eventData!['imageUrl'] ?? '') : '',
        'attendees': int.tryParse(_attendeesController.text.trim()) ?? 0,
      };

      final eventService = EventService();

      if (widget.eventId != null) {
        // Update existing event
        await eventService.updateEvent(widget.eventId!, eventData);
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Event updated successfully!', isError: false);
          Navigator.pop(context);
        }
      } else {
        // Create new event (includes createdAt)
        eventData['createdAt'] = FieldValue.serverTimestamp();
        await eventService.addEvent(eventData);
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar('Event created successfully!', isError: false);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error saving event: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isError ? '❌ $message' : '✅ $message'),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Event' : 'Create Event',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Event Title
                _buildLabel('Event Title'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hintText: 'Enter event title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                _buildLabel('Description'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'Describe your event',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location
                _buildLabel('Location Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hintText: 'e.g., Central Park',
                  prefixIcon: Icons.place_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Address
                _buildLabel('Address'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _addressController,
                  hintText: 'e.g., New York, NY',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date Picker
                _buildLabel('Event Date'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Select event date'
                              : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Pickers Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Time'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectStartTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startTime == null ? 'Start' : _formatTimeOfDay(_startTime!),
                                    style: TextStyle(
                                      color: _startTime == null ? Colors.grey : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          InkWell(
                            onTap: _selectEndTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _endTime == null ? 'End' : _formatTimeOfDay(_endTime!),
                                    style: TextStyle(
                                      color: _endTime == null ? Colors.grey : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                _buildLabel('Category'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price
                _buildLabel('Ticket Price (\$)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _priceController,
                  hintText: '0.00',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ticket price (0 for free)';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Expected Attendees
                _buildLabel('Expected Attendees'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _attendeesController,
                  hintText: 'Number of expected attendees',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.people_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expected attendees';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                _isLoading
                    ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B4EFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
                    : ElevatedButton(
                  onPressed: _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4EFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.eventId != null ? 'UPDATE EVENT' : 'CREATE EVENT',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B4EFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}