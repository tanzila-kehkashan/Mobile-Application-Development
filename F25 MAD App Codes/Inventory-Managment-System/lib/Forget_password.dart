import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'Login_page.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors ---
class AppColors {
  static const Color primaryText = Colors.black;
  static const Color secondaryText = Color(0xFF8A91A5);
  static const Color backgroundColor = Color(0xFFF0F4F9);
  static const Color buttonColor = Color(0xFF6A99E0);
  static const Color textFieldBackground = Colors.white;
  static const Color iconColor = Color(0xFF6A99E0);
  static const Color tealAccent = Color(0xFF70B8C0);
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
      ),
      home: const ForgotPasswordPage(),
    );
  }
}

// --- 2. Forgot Password Page with Firebase ---
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Top Navigation (Back Arrow) ---
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.black,
              ),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // --- 2. Illustration ---
          Center(
            child: Container(
              height: 200,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lock icon
                  Positioned(
                    top: 20,
                    child: Icon(
                      Icons.lock_outline,
                      size: 120,
                      color: AppColors.iconColor.withOpacity(0.8),
                    ),
                  ),
                  // Key icon
                  Positioned(
                    bottom: 30,
                    right: 50,
                    child: Icon(
                      Icons.vpn_key,
                      size: 60,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  // Email icon
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: Color(0xFF4A7AB0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- 3. Title ---
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: 12),

          // --- 4. Subtitle ---
          const Text(
            'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // --- 5. Email Field ---
          const Text(
            "Email Address",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // --- 6. Send Reset Link Button ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 30),

          // --- 7. Back to Login ---
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: RichText(
                text: const TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                  ),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: AppColors.buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),

        // Success Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 80,
            color: Colors.green,
          ),
        ),

        const SizedBox(height: 40),

        // Title
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          'We\'ve sent a password reset link to:',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Email
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonColor,
          ),
        ),

        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInstructionStep('1', 'Open the email from Firebase'),
              const SizedBox(height: 16),
              _buildInstructionStep('2', 'Click the password reset link'),
              const SizedBox(height: 16),
              _buildInstructionStep('3', 'Create your new password'),
              const SizedBox(height: 16),
              _buildInstructionStep('4', 'Return to login'),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Back to Login Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Resend Link
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text(
            'Didn\'t receive email? Try again',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
