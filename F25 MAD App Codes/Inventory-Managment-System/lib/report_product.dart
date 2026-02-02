import 'package:flutter/material.dart';
import 'main_dashboard.dart';
import 'main_profile.dart';
import 'total_stock.dart';
import 'reports_screen.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors (Consistent with previous screens) ---
class AppColors {
  // Primary App Colors
  static const Color accentOrange = Color(0xFFE08F4C);
  static const Color primaryText = Colors.black;
  static const Color backgroundColor = Color(
    0xFFF0F4F9,
  ); // Very light blue/lavender
  static const Color buttonColor = Color(0xFF70B8C0); // Muted teal/cyan
  static const Color illustrationColor = Color(0xFF6A99E0);
  static const Color textFieldBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE5E5E5);

  // Home Screen Colors
  static const Color searchBarBackground = Colors.white;
  static const Color actionButtonBackground = Color(
    0xFFE5E5E5,
  ); // Light grey for Add/Scan buttons
  static const Color lowStockAlertBackground = Color(
    0xFFFFCCCC,
  ); // Light Red/Pink for alert
  static const Color bottomNavColor = Color(
    0xFF6B7280,
  ); // Darker grey for bottom bar
  static const Color bottomNavActiveColor = Colors.white;

  // New Report Page Colors
  static const Color submitButtonColor = Color(
    0xFF1F487B,
  ); // Deep blue for the submit button
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Inventory',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryText),
        ),
      ),
      // Set the new ReportProductPage as the initial screen for preview
      home: const ReportProductPage(),
    );
  }
}

// --- 2. Shared Custom Widgets ---

// Action Button matching the design (Add/Scan)
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.actionButtonBackground,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Custom Bottom Navigation Bar matching the image
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: AppColors.bottomNavColor),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            _buildNavItem(0, 'Home', Icons.home_outlined),
            _buildNavItem(1, 'Product', Icons.shopping_bag_outlined),
            _buildNavItem(2, 'Report', Icons.insert_chart_outlined),
            _buildNavItem(3, 'Profile', Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final bool isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onItemTapped(index),
        child: Container(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.bottomNavActiveColor
                    : AppColors.bottomNavActiveColor.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.bottomNavActiveColor
                      : AppColors.bottomNavActiveColor.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Form Field specifically for the Report Page
class ReportTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final int maxLines;
  final bool isDatePicker;

  const ReportTextField({
    super.key,
    this.label,
    required this.hint,
    this.maxLines = 1,
    this.isDatePicker = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
            child: Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryText,
              ),
            ),
          ),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.primaryText.withOpacity(0.5),
              // Hint text color matches the light blue background color (E5E5E5)
            ),
            filled: true,
            fillColor: AppColors.textFieldBackground,
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 20.0 : 18.0,
              horizontal: 20.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.submitButtonColor,
                width: 2.0,
              ),
            ),
            // For the date picker style:
            suffixIcon: isDatePicker
                ? const Icon(Icons.calendar_today, size: 20)
                : null,
          ),
        ),
        // Add minimal spacing between fields if a label is present
        if (label != null) const SizedBox(height: 5),
      ],
    );
  }
}

// --- 3. Report Product Page (Matching Setting (1).png) ---
class ReportProductPage extends StatefulWidget {
  const ReportProductPage({super.key});

  @override
  State<ReportProductPage> createState() => _ReportProductPageState();
}

class _ReportProductPageState extends State<ReportProductPage> {
  int _selectedIndex = 2; // Report tab is selected

  // Controllers for form fields
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _categoryController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Show date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.submitButtonColor,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
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
      // After date is picked, show time picker
      _pickTime();
    }
  }

  // Show time picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.submitButtonColor,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _updateDateTimeText();
      });
    }
  }

  void _updateDateTimeText() {
    if (_selectedDate != null) {
      String dateText =
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      if (_selectedTime != null) {
        final hour = _selectedTime!.hourOfPeriod == 0
            ? 12
            : _selectedTime!.hourOfPeriod;
        final minute = _selectedTime!.minute.toString().padLeft(2, '0');
        final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
        dateText += ' - $hour:$minute $period';
      }
      _dateTimeController.text = dateText;
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Already on this tab

    switch (index) {
      case 0:
        // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHomePage()),
        );
        break;
      case 1:
        // Product -> Total Stock
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TotalStockScreen()),
        );
        break;
      case 2:
        // Already on Report
        break;
      case 3:
        // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfilePage()),
        );
        break;
    }
  }

  void _submitReport() {
    // Validate fields
    if (_categoryController.text.isEmpty) {
      _showError('Please select incident category');
      return;
    }
    if (_detailsController.text.isEmpty) {
      _showError('Please add details');
      return;
    }
    if (_dateTimeController.text.isEmpty) {
      _showError('Please select date and time');
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Report submitted successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Clear form
    _categoryController.clear();
    _detailsController.clear();
    _locationController.clear();
    _dateTimeController.clear();
    _descriptionController.clear();
    _selectedDate = null;
    _selectedTime = null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                'Report Product',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),

            // --- Form Content Area ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Select incident category (Dropdown style)
                    _buildTextField(
                      controller: _categoryController,
                      hint: 'Select the incident category',
                    ),

                    // 2. Add the details (Short text field with label above)
                    _buildTextField(
                      controller: _detailsController,
                      label: 'Add the details to submit your report',
                      hint: 'Enter details...',
                    ),

                    // 3. Location (Short text field with label above)
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location where incident happened',
                      hint: 'Enter location...',
                    ),

                    // 4. Date and time (Tappable field that opens pickers)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 15.0),
                      child: Text(
                        'Date and time of incident',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dateTimeController,
                          decoration: InputDecoration(
                            hintText: 'Tap to select date & time',
                            hintStyle: TextStyle(
                              color: AppColors.primaryText.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: AppColors.textFieldBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 20.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: AppColors.dividerColor,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(
                                color: AppColors.dividerColor,
                                width: 1.0,
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // 5. Details of what happened (Large text area with label above)
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Details of what happened',
                      hint: 'Describe what happened...',
                      maxLines: 8,
                    ),

                    const SizedBox(height: 40),

                    // --- Submit Report Button ---
                    Container(
                      width: double.infinity,
                      height: 55,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.submitButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Submit report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Navigation Bar ---
            CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryText,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.primaryText.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.textFieldBackground,
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 20.0 : 18.0,
              horizontal: 20.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.submitButtonColor,
                width: 2.0,
              ),
            ),
          ),
        ),
        if (label != null) const SizedBox(height: 5),
      ],
    );
  }
}

// Placeholder classes for the rest of the application screens
// You can uncomment these and fill them in with the code from previous steps
/*
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Splash Page')));
  }
}
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Welcome Page')));
  }
}
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Sign In Page')));
  }
}
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Sign Up Page')));
  }
}
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Forgot Password Page')));
  }
}
class EnterCodePage extends StatelessWidget {
  const EnterCodePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Enter Code Page')));
  }
}
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('My Profile Page')));
  }
}
class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Main Home Page')));
  }
}
*/
