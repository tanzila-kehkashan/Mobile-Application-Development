import 'package:flutter/material.dart';
import 'src/views/screens/splash_screen.dart'; // Ensure this file exists
import 'src/views/screens/login.dart';  // Ensure this file exists
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/views/screens/welcome_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final AuthService _authService = AuthService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Check initial link
    try {
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _handleLink(appLink);
      }
    } catch(e) {
      debugPrint("Error getting initial link: $e");
    }

    // Subscribe to link changes
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) {
    debugPrint("Received Deep Link: $uri");
    String link = uri.toString();
    
    if (_authService.isSignInWithEmailLink(link)) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => EmailAuthHandlerScreen(link: link),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Quizzy App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Inter',
      ),
      // Use AuthWrapper as the home to handle all initial routing
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _timerDone = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Start the mandatory 3-second splash timer
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _timerDone = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // 1. If timer isn't done OR auth state is still loading, show splash view
        if (!_timerDone || snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }

        final user = snapshot.data;

        // 2. If no user, go to Login
        if (user == null) {
          return const LoginScreen();
        }

        // 3. If user exists, we check verification status
        // We can use a FutureBuilder here for the async check
        return FutureBuilder<bool>(
          future: _authService.isEmailVerified(),
          builder: (context, verifySnapshot) {
            // Show splash view until verification check is done
            if (verifySnapshot.connectionState == ConnectionState.waiting) {
              return const SplashView();
            }

            if (verifySnapshot.data == true) {
              return const WelcomeScreen();
            } else {
              // Not verified or error, stay on login
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

// A static version of the splash screen without the timer logic
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: size.width * 0.6,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quizzy',
              style: TextStyle(
                color: Color(0xFF00E5BC),
                fontSize: 64,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Handler Screen to Complete Sign In
class EmailAuthHandlerScreen extends StatefulWidget {
  final String link;
  const EmailAuthHandlerScreen({super.key, required this.link});

  @override
  State<EmailAuthHandlerScreen> createState() => _EmailAuthHandlerScreenState();
}

class _EmailAuthHandlerScreenState extends State<EmailAuthHandlerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             const Text("Please confirm your email to complete sign-in:"),
             const SizedBox(height: 10),
             TextField(
               controller: _emailController,
               decoration: const InputDecoration(labelText: "Email"),
             ),
             const SizedBox(height: 20),
             if (_statusMessage != null) ...[
               Text(_statusMessage!, style: const TextStyle(color: Colors.red)),
               const SizedBox(height: 10),
             ],
             ElevatedButton(
               onPressed: _isLoading ? null : _finishSignIn, 
               child: _isLoading ? const CircularProgressIndicator() : const Text("Verify & Login")
             ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSignIn() async {
    setState(() { _isLoading = true; _statusMessage = null; });
    try {
      await _authService.signInWithEmailLink(_emailController.text.trim(), widget.link);
      if (mounted) {
         // Restart app to go to main logic (which will see user is logged in via StreamBuilder in Login/Splash if implemented, 
         // OR we just navigate to Dashboard if we had the import. 
         // For now, let's push replacement.
         // Assuming Dashboard exists: 
         // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
         // But we don't have dashboard import here.
         // Let's just pop safely or provide success message.
         
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!")));
         // Go back to root (which should update to logged in state if using StreamBuilder)
         Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}