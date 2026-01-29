import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- This fixes the "Firebase" error
import 'src/views/screens/splash_screen.dart'; // <--- This fixes the "SplashScreen" error

void main() async {
  // 1. Initialize the binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp();

  // 3. Print success message
  print("✅ FIREBASE IS CONNECTED SUCCESSFULLY! ✅");

  // 4. Run the App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}