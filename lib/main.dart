import 'package:event_hub/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'auth_screens/login.dart';
import 'nav_bar.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'services/enhanced_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Enhanced Notification Service
  await EnhancedNotificationService().initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFCM();
    });
  }

  Future<void> _initializeFCM() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      print('✅ FCM initialized successfully');
    } catch (e) {
      print('⚠️ FCM initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // 1. Watch the AsyncNotifier version of the theme
    final themeModeAsync = ref.watch(themeModeProvider);

    // 2. Use .when to handle the loading state of the theme
    return themeModeAsync.when(
      data: (themeMode) => MaterialApp(
        title: 'EventHub',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode, // Now safely passes ThemeMode
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF5B4EFF),
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5B4EFF),
            secondary: Color(0xFF00D9A5),
            surface: Colors.white,
            error: Color(0xFFFF6B6B),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF5B4EFF),
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF5B4EFF),
            secondary: Color(0xFF00D9A5),
            surface: Color(0xFF1E1E1E),
            error: Color(0xFFFF6B6B),
          ),
        ),
        home: authState.when(
          data: (user) => user != null ? const MainNavigation() : const SignInScreen(),
          loading: () => const LoadingWidget(),
          error: (error, _) => ErrorWidget(error),
        ),
      ),
      // 3. Fallback UI while SharedPreferences is reading the theme
      loading: () => const MaterialApp(
        home: LoadingWidget(),
      ),
      error: (error, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Theme Error: $error'))),
      ),
    );
  }
}

// Simple internal helper for the loading state
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF5B4EFF)),
      ),
    );
  }
}