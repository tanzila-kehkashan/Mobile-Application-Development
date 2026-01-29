import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';
import 'login_screen.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isResending = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      await _authService.resendVerificationEmail();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Email Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: AppSizes.iconXL(context),
                  color: const Color(0xFF007AFF),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: AppSizes.fontXL(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a verification link to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontM(context),
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Email Address
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontM(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007AFF),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: EdgeInsets.all(AppSizes.paddingM(context)),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please check your email and click the verification link to activate your account.',
                            style: TextStyle(
                              fontSize: AppSizes.fontS(context),
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'After verifying, return to the app and log in with your credentials.',
                            style: TextStyle(
                              fontSize: AppSizes.fontS(context),
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Resend Email Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                    ),
                    side: const BorderSide(color: Color(0xFF007AFF)),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                          ),
                        )
                      : Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            fontSize: AppSizes.fontM(context),
                            color: const Color(0xFF007AFF),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Back to Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      FadeSlidePageRoute(page: const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                    ),
                  ),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: AppSizes.fontM(context),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Help Text
              Text(
                'Didn\'t receive the email? Check your spam folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontS(context),
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
