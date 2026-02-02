import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/utils/page_transitions.dart';
import 'package:momentum/features/auth/presentation/screens/register_screen.dart';
import 'package:momentum/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:momentum/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:momentum/features/home/presentation/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSettings();
  }

  Future<void> _checkBiometricSettings() async {
    _biometricAvailable = await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
    
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    
    // Also get saved email for biometric login
    if (_biometricEnabled) {
      _emailController.text = prefs.getString('biometric_email') ?? '';
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Login to Momentum with biometrics',
      );
      
      if (authenticated && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('biometric_email');
        final savedPassword = prefs.getString('biometric_password');
        
        if (savedEmail != null && savedPassword != null) {
          setState(() => _isLoading = true);
          
          final appState = AppStateProvider.of(context);
          final result = await appState.login(
            email: savedEmail,
            password: savedPassword,
          );
          
          setState(() => _isLoading = false);
          
          if (!mounted) return;
          
          if (result.success) {
            if (appState.authService.isEmailVerified) {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRoute(page: const DashboardScreen()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRoute(page: EmailVerificationScreen(email: savedEmail)),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Login failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No saved credentials. Please login with email first.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appState = AppStateProvider.of(context);
    final result = await appState.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      // Save credentials for biometric login if enabled
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('biometric_enabled') ?? false) {
        await prefs.setString('biometric_email', _emailController.text.trim());
        await prefs.setString('biometric_password', _passwordController.text);
      }
      
      // Check if email is verified
      if (appState.authService.isEmailVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(page: const DashboardScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Email not verified, redirect to verification screen
        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(page: EmailVerificationScreen(email: _emailController.text.trim())),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 50),
              const SizedBox(height: 20),
              const Text(
                'Welcome back! Glad to see you, Again!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF4A3D7E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.orangeAccent),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF4A3D7E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.orangeAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF201A3F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              // Biometric login button
              if (_biometricEnabled && _biometricAvailable) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleBiometricLogin,
                    icon: const Icon(Icons.fingerprint, color: Colors.white),
                    label: const Text(
                      'Login with Biometrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(page: const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register Now',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
