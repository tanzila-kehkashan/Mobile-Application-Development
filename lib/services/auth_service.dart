import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with Email and Password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Facebook Sign-In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        // User cancelled or error occurred
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Sign in to Firebase with the Facebook credential
      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);

      // Create user document if it doesn't exist
      if (userCredential.user != null) {
        await _createUserDocumentIfNotExists(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Create user document in Firestore if it doesn't exist
  Future<void> _createUserDocumentIfNotExists(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'followerCount': 0,
        'followingCount': 0,
      });
    }
  }

  // Remember Me - Save credentials
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
    await _secureStorage.write(key: 'rememberMe', value: 'true');
  }

  // Get saved credentials
  Future<Map<String, String?>> getSavedCredentials() async {
    final rememberMe = await _secureStorage.read(key: 'rememberMe');
    if (rememberMe == 'true') {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      return {'email': email, 'password': password};
    }
    return {'email': null, 'password': null};
  }

  // Clear saved credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'password');
    await _secureStorage.delete(key: 'rememberMe');
  }

  // Auto-login with saved credentials
  Future<UserCredential?> autoLogin() async {
    try {
      final credentials = await getSavedCredentials();
      final email = credentials['email'];
      final password = credentials['password'];

      if (email != null && password != null) {
        return await signInWithEmailPassword(email, password);
      }
      return null;
    } catch (e) {
      print('Auto-login failed: $e');
      await clearCredentials();
      return null;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // Sign out and clear credentials
  Future<void> signOutAndClearCredentials() async {
    await clearCredentials();
    await signOut();
  }
}
