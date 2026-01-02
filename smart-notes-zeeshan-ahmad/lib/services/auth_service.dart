import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as local_user;
import 'local_storage_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<local_user.User?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      // Fetch user data from Firestore
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          return local_user.User.fromFirestore(doc.data()!, doc.id);
        }
        // Fallback if user doc doesn't exist yet (shouldn't happen if registered correctly)
        return local_user.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
        );
      } catch (e) {
        print('Error fetching user data: $e');
        // Return a basic user object even if we can't fetch from Firestore
        return local_user.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
        );
      }
    });
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Save user to local storage
      final user = await getCurrentUser();
      if (user != null) {
        await LocalStorageService().saveUser(user.name, user.email);
      }
      
      return null; // No error
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      return '${e.code}: ${e.message}';
    } catch (e) {
      print('Login error: $e');
      return 'Unknown error: $e';
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final user = local_user.User(
          id: credential.user!.uid,
          name: name,
          email: email,
        );
        await _firestore.collection('users').doc(user.id).set(user.toJson());
        
        // Save to local storage
        await LocalStorageService().saveUser(name, email);
        
        return null; // No error
      }
      return 'Failed to create user credential';
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      return '${e.code}: ${e.message}';
    } catch (e) {
      print('Registration error: $e');
      return 'Unknown error: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await LocalStorageService().clearUser();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<local_user.User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return local_user.User.fromFirestore(doc.data()!, doc.id);
      }
      return local_user.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
      );
    } catch (e) {
      print('Error fetching current user: $e');
      // Return a basic user object even if we can't fetch from Firestore
      return local_user.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
      );
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Reset password error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  /// Update password for a user after OTP verification
  /// Note: This requires the user to have recently signed in or use a workaround
  /// For security, we'll use Firebase's password reset email as a backup
  Future<String?> updatePasswordWithEmail(String email, String newPassword) async {
    try {
      // Check if there's a current user signed in
      final currentUser = _auth.currentUser;
      
      if (currentUser != null && currentUser.email == email) {
        // User is already signed in, update password directly
        await currentUser.updatePassword(newPassword);
        print('Password updated successfully for signed-in user');
        return null; // Success
      }
      
      // For users not signed in, we need to use a different approach
      // Firebase doesn't allow password updates without authentication
      // The proper flow is:
      // 1. User proves ownership via OTP (which we've already done)
      // 2. We send a password reset email (Firebase's secure way)
      // 3. User clicks link and sets new password
      
      // However, since user wants inline password reset, we'll try to sign them in first
      // This requires knowing their current password, which we don't have
      
      // Alternative: Use Firebase Admin SDK on server-side (not available in Flutter client)
      // For now, we'll store the new password request and send reset email as backup
      
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
      
      // Store in Firestore that user requested password change (for reference)
      final userDocs = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userDocs.docs.isNotEmpty) {
        await _firestore.collection('password_reset_requests').add({
          'email': email,
          'requestedAt': DateTime.now().toIso8601String(),
          'status': 'pending',
        });
      }
      
      return null; // Success - email sent
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Update password error: ${e.code} - ${e.message}');
      return '${e.code}: ${e.message}';
    } catch (e) {
      print('Update password error: $e');
      return 'Error updating password: $e';
    }
  }
  /// Send password reset email after OTP verification
  /// This is the secure way to let user set a new password
  Future<String?> sendPasswordResetWithNewPassword(String email, String newPassword) async {
    try {
      // Send Firebase password reset email
      // This is the secure way since Firebase doesn't allow password updates without auth
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
      
      // Log password reset request in Firestore for tracking
      try {
        await _firestore.collection('password_reset_requests').add({
          'email': email,
          'requestedAt': DateTime.now().toIso8601String(),
          'status': 'email_sent',
          'method': 'otp_verified',
        });
      } catch (firestoreError) {
        print('Could not log reset request: $firestoreError');
        // Continue anyway - email was sent
      }
      
      return null; // Success
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Send reset email error: ${e.code} - ${e.message}');
      return '${e.code}: ${e.message}';
    } catch (e) {
      print('Send reset email error: $e');
      return 'Error sending reset email: $e';
    }
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}