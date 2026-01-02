
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_notes/models/user.dart' as local_user;
import 'package:smart_notes/services/auth_service.dart';
import 'package:smart_notes/services/note_service.dart';
import 'package:smart_notes/services/database_service.dart';
import 'package:smart_notes/services/ocr_service.dart';
import 'package:smart_notes/services/otp_service.dart';
import 'package:smart_notes/screens/login_screen.dart';
import 'package:smart_notes/screens/my_notes_screen.dart';
import 'package:smart_notes/screens/splash_screen.dart';
import 'utils/app_router.dart';
import 'utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_notes/services/settings_service.dart';
import 'package:smart_notes/utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wrap everything in error zone to catch initialization errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
  };
  
  try {
    // Robust .env loading - use asset bundle (works on all platforms)
    try {
      await dotenv.load(fileName: ".env");
      print("Success: Loaded .env from assets.");
    } catch (e) {
      print("Warning: dotenv loading failed: $e");
      // Continue without .env - Firebase options are hardcoded anyway
    }
    
    // Initialize Firebase (with duplicate prevention)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("Success: Firebase initialized.");
      } else {
        print("Firebase already initialized, skipping.");
      }
    } catch (e) {
      // If error is duplicate-app, that's fine - Firebase is already ready
      if (e.toString().contains('duplicate-app')) {
        print("Firebase was already initialized by native code, continuing...");
      } else {
        rethrow; // Re-throw other errors
      }
    }
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print("Critical initialization error: $e");
    print("Stack trace: $stackTrace");
    // Show error app instead of blank screen
    runApp(ErrorApp(error: e.toString()));
  }
}

// Error fallback app to show initialization errors
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        StreamProvider<local_user.User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
        ChangeNotifierProxyProvider<local_user.User?, NoteService>(
          create: (context) => NoteService(null),
          update: (context, user, previous) => NoteService(user?.id),
        ),
        Provider<OCRService>(
          create: (_) => OCRService(),
        ),
        Provider<OtpService>(
          create: (_) => OtpService(),
        ),
        ProxyProvider<local_user.User?, DatabaseService>(
          update: (context, user, previous) => DatabaseService(user?.id),
        ),
        ChangeNotifierProvider(create: (_) => SettingsService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Smart Notes',
            debugShowCheckedModeBanner: false,
            theme: settings.isColorBlindMode 
                ? AppTheme.colorBlindTheme 
                : AppTheme.lightTheme,
            darkTheme: settings.isColorBlindMode
                ? AppTheme.colorBlindTheme // Color blind mode overrides dark mode preference for visual clarity
                : AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
              Locale('fr', ''),
            ],
            home: const SplashScreen(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local_user.User?>(context);

    if (user != null) {
      return const MyNotesScreen();
    } else {
      return const LoginScreen();
    }
  }
}
