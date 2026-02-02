import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send email verification to current user
  Future<AuthResult> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        return AuthResult.failure(message: 'No user logged in');
      }
      await currentUser!.sendEmailVerification();
      return AuthResult.success(message: 'Verification email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Reload current user data from Firebase
  Future<AuthResult> reloadUser() async {
    try {
      if (currentUser == null) {
        return AuthResult.failure(message: 'No user logged in');
      }
      await currentUser!.reload();
      return AuthResult.success(user: _auth.currentUser);
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Register with email and password
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return AuthResult.success(user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      // Show the actual exception for debugging
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Send password reset email (real OTP via email)
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Confirm password reset with code from email
  Future<AuthResult> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Verify password reset code
  Future<AuthResult> verifyPasswordResetCode(String code) async {
    try {
      final email = await _auth.verifyPasswordResetCode(code);
      return AuthResult.success(email: email);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) {
        return AuthResult.failure(message: 'No user logged in');
      }

      if (displayName != null) {
        await currentUser!.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      return AuthResult.success(user: currentUser);
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Update email
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      if (currentUser == null) {
        return AuthResult.failure(message: 'No user logged in');
      }

      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      return AuthResult.success(message: 'Verification email sent to $newEmail');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      if (currentUser == null) {
        return AuthResult.failure(message: 'No user logged in');
      }

      await currentUser!.delete();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } on FirebaseException catch (e) {
      return AuthResult.failure(message: _getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(message: 'Error: ${e.runtimeType} - $e');
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please enable it in Firebase Console.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'expired-action-code':
        return 'This code has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'Invalid code. Please check and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'unknown':
        return 'Unknown error. Please check if Email/Password auth is enabled in Firebase Console.';
      case 'CONFIGURATION_NOT_FOUND':
        return 'Firebase not configured. Please check google-services.json.';
      default:
        return 'Auth error ($code). Please check Firebase Console settings.';
    }
  }
}

/// Result class for auth operations
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? email;

  AuthResult._({
    required this.success,
    this.message,
    this.user,
    this.email,
  });

  factory AuthResult.success({User? user, String? message, String? email}) {
    return AuthResult._(success: true, user: user, message: message, email: email);
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(success: false, message: message);
  }
}
