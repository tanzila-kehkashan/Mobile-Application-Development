import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/firebase_options.dart';
import 'package:momentum/core/state/app_state.dart';
import 'package:momentum/core/services/storage_service.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/core/services/connectivity_service.dart';
import 'package:momentum/core/services/firestore_service.dart';
import 'package:momentum/core/widgets/offline_banner.dart';
import 'package:momentum/features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore offline persistence for real-time data caching
  await FirestoreService().enableOfflinePersistence();
  
  // Initialize connectivity service
  await ConnectivityService().initialize();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final authService = AuthService();
  final appState = AppState(storageService, authService);
  
  // Initialize app state
  await appState.initialize();
  
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  
  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      appState: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Momentum',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Montserrat Alternates',
        ),
        home: const OfflineBanner(
          child: SplashScreen(),
        ),
      ),
    );
  }
}

