import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTS ---
import 'sign_in.dart';
import 'verify_email.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // --- State Variables ---
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Toggle for Password
  bool _isConfirmVisible = false;  // Toggle for Confirm Password

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // --- SIGN UP LOGIC ---
  void _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmController.text.trim();

    FocusScope.of(context).unfocus();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': name,
          'email': email,
          'uid': user.uid,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'age': '--',
          'height': '--',
          'weight': '--',
          'gender': '--',
        });

        await user.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created! Please check your email."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      String message = "Registration failed.";
      if (e.code == 'email-already-in-use') message = "This email is already in use.";
      else if (e.code == 'weak-password') message = "Password is too weak.";
      else if (e.code == 'invalid-email') message = "Invalid email address.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
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
        iconTheme: const IconThemeData(color: Colors.white),
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
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please enter your details below',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- 1. Full Name ---
                _buildInputField(
                  hint: "Full Name",
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 20),

                // --- 2. Email ---
                _buildInputField(
                  hint: "Email",
                  icon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),

                // --- 3. Password (With Eye Icon) ---
                _buildPasswordField(
                  hint: "Password",
                  controller: _passwordController,
                  isVisible: _isPasswordVisible,
                  onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 20),

                // --- 4. Confirm Password (With Eye Icon) ---
                _buildPasswordField(
                  hint: "Confirm Password",
                  controller: _confirmController,
                  isVisible: _isConfirmVisible,
                  onToggle: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),
                const SizedBox(height: 50),

                // --- SIGN UP BUTTON ---
                GestureDetector(
                  onTap: _isLoading ? null : _handleSignUp,
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
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- FOOTER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER 1: Regular Input Field (Name, Email) ---
  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          // FIX: Changed "grey_button.png" to "grey_buttion.png"
          image: AssetImage('assets/images/grey_buttion.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            icon: Icon(icon, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  // --- HELPER 2: Password Field (With Eye Icon) ---
  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          // FIX: Changed "grey_button.png" to "grey_buttion.png"
          image: AssetImage('assets/images/grey_buttion.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            icon: const Icon(Icons.lock_outline, color: Colors.black54),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ),
    );
  }
}