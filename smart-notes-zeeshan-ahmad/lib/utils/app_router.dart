import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/my_notes_screen.dart';
import '../screens/about_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/help_screen.dart';
import '../screens/user_guide_screen.dart';
import '../screens/new_note_screen.dart';
import '../screens/note_details_screen.dart';
import '../screens/edit_note_screen.dart';
import '../screens/scan_note_screen.dart';
import '../screens/extracted_text_screen.dart';
import '../screens/search_screen.dart';
import '../screens/tags_categories_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/verify_otp_screen.dart';
import '../screens/set_new_password_screen.dart';
import '../screens/database_demo_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case '/verify-otp':
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(email: email),
        );
      case '/set-new-password':
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => SetNewPasswordScreen(email: email),
        );
      case '/my-notes':
        return MaterialPageRoute(builder: (_) => const MyNotesScreen());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/privacy-policy':
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case '/terms-of-service':
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
      case '/help':
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case '/user-guide':
        return MaterialPageRoute(builder: (_) => const UserGuideScreen());
      case '/new-note':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NewNoteScreen(initialContent: args?['initialContent']),
        );
      case '/note-details':
        final noteId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => NoteDetailsScreen(noteId: noteId ?? ''),
        );
      case '/edit-note':
        final noteId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => EditNoteScreen(noteId: noteId ?? ''),
        );
      case '/scan-note':
        return MaterialPageRoute(builder: (_) => const ScanNoteScreen());
      case '/extracted-text':
        final text = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ExtractedTextScreen(extractedText: text ?? ''),
        );
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/tags-categories':
        return MaterialPageRoute(builder: (_) => const TagsCategoriesScreen());
      case '/database-demo':
        return MaterialPageRoute(builder: (_) => const DatabaseDemoScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}