import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Database
import 'package:firebase_auth/firebase_auth.dart';     // Auth

// --- Import navigation screens ---
import 'dashboard.dart';
import 'profile.dart';
import 'schedule.dart';
import 'settings.dart';

class RattingsScreen extends StatefulWidget {
  const RattingsScreen({super.key});

  @override
  State<RattingsScreen> createState() => _RattingsScreenState();
}

class _RattingsScreenState extends State<RattingsScreen> {
  // --- STATE VARIABLES ---
  int _currentRating = 4; // Default starts at 4 stars
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // --- LOGIC: SUBMIT FEEDBACK TO DATABASE ---
  Future<void> _submitFeedback() async {
    // 1. Hide Keyboard
    FocusScope.of(context).unfocus();

    String feedbackText = _feedbackController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in!")));
      return;
    }

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write some feedback before submitting."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Save to Firestore
      await FirebaseFirestore.instance.collection('app_feedback').add({
        'uid': user.uid,
        'email': user.email,
        'rating': _currentRating,
        'feedback': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Success Message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Thank you! Feedback saved."),
              backgroundColor: Colors.green
          ),
        );

        // Reset the form
        _feedbackController.clear();
        setState(() {
          _currentRating = 5;
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/back_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Row(
          children: [
            // --- CUSTOM HEADER ICON (ratting_icon.png) ---
            Image.asset(
              'assets/images/ratting_icon.png',
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Ratting And Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Slightly smaller to fit
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SizedBox(
              width: 35,
              height: 35,
              child: Image.asset('assets/images/notification_icon.png'),
            ),
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // --- Feedback Label ---
                      const Text(
                        'Give us your feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --- Feedback Text Box ---
                      Container(
                        height: 180,
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85), // White transparent box
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 8,
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'write something',
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- Rating Section ---
                      const Text(
                        'Rate Us:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --- CUSTOM STAR ROW ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (index) {
                          // Logic: If the star index is less than rating, show your "star.png"
                          // Otherwise show an empty outline icon
                          bool isSelected = index < _currentRating;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentRating = index + 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: isSelected
                              // FILLED STATE: Use your 'star.png'
                                  ? Image.asset(
                                'assets/images/star.png',
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                              )
                              // EMPTY STATE: Use outline icon to match design
                                  : const Icon(
                                Icons.star_border_rounded,
                                color: Colors.white30,
                                size: 50,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 50),

                      // --- SUBMIT BUTTON ---
                      GestureDetector(
                        onTap: _isLoading ? null : _submitFeedback,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/button_gradient_bg.png'),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1E35),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.fitness_center, "Dashboard", false),
                    _buildNavItem(context, Icons.settings, "Setting", true), // Active
                    _buildNavItem(context, Icons.calendar_month, "Schedule", false),
                    _buildNavItem(context, Icons.person, "Your Profile", false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: Nav Item ---
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "Dashboard") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        } else if (label == "Your Profile") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        } else if (label == "Schedule") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScheduleScreen()));
        } else if (label == "Setting") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? Colors.cyan : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.cyan : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}