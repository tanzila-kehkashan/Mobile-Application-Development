import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Database
import 'package:firebase_auth/firebase_auth.dart';     // Auth
import 'profile.dart'; // <--- Import Profile to navigate there

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --- FUNCTION: SAVE TO FIREBASE ---
  Future<void> _saveProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No user logged in!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update Firestore Document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _genderController.text.trim(),
        'height': _heightController.text.trim(),
        'weight': _weightController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
        );

        // --- NAVIGATION CHANGE ---
        // Instead of popping back, we force navigation to the Profile Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.red),
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
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.asset('assets/images/back_icon.png', fit: BoxFit.contain),
          ),
        ),
        title: const Text(
          'Edit Your Profile',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _buildLabelAndField('NEW NAME:', _nameController),
                _buildLabelAndField('NEW AGE:', _ageController),
                _buildLabelAndField('GENDER:', _genderController),
                _buildLabelAndField('HEIGHT:', _heightController),
                _buildLabelAndField('WEIGHT:', _weightController),

                const SizedBox(height: 30),

                // --- SAVE BUTTON ---
                GestureDetector(
                  onTap: _isLoading ? null : _saveProfile,
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
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

  // --- Helper Widget: Label + Grey Input Box ---
  Widget _buildLabelAndField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),

        // --- INPUT CONTAINER ---
        Container(
          width: double.infinity,
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            // 1. Fallback Color: Ensures box is visible even if image fails
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10), // Rounded corners
            // 2. Image: Tries to load the asset on top
            image: const DecorationImage(
              image: AssetImage('assets/images/grey_buttion.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.black87), // Dark text for contrast
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}