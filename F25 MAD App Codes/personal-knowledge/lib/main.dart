import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 1. Add this import
import 'package:flutter_quill/flutter_quill.dart'; // 2. Add this import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// Main function updated to initialize Firebase
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KnowBase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        scaffoldBackgroundColor: Colors.white,
      ),

      // 3. Add this Localization Setup to fix the Red Screen Error
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // This is the required line
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Supports English
      ],

      home: SplashScreen(),
    );
  }
}