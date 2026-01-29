import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create User Document (if not exists)
  Future<void> createUserDocument(String uid, String email, {String role = 'user'}) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          // Default display name can ideally be set here too if available
        });
      }
    } catch (e) {
      throw 'Error creating user profile: $e';
    }
  }

  // Get User Role
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] ?? 'user';
      }
      return 'user'; // Default to user if no doc
    } catch (e) {
      // In a real app, you might want to log this
      return 'user';
    }
  }

  // Sign Up
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign In
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Auto-repair on login
      if (credential.user != null) {
        await createUserDocument(credential.user!.uid, email);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  // Check if current user is verified (must reload to get latest status)
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Refresh user state from Firebase
      return _auth.currentUser!.emailVerified;
    }
    return false;
  }

  // Send Sign-In Link to Email
  Future<void> sendSignInWithEmailLink(String email) async {
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://quizzapp-1bebf.firebaseapp.com/login', // Must match one in Console
      handleCodeInApp: true,
      iOSBundleId: 'com.example.quizzApp', // Update if different
      androidPackageName: 'com.example.quizz_app',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  // Check if link is a sign-in link
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  // Sign In with Email Link
  Future<UserCredential> signInWithEmailLink(String email, String link) async {
    return await _auth.signInWithEmailLink(email: email, emailLink: link);
  }

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Update Display Name
  Future<void> updateDisplayName(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
        await user.reload(); // Reload to get updated info
        
        // Also update in 'users' collection with merge to safe-guard against missing docs
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': name,
          // We can also ensure email is there if we want, but name is enough for now
        }, SetOptions(merge: true));
      } catch (e) {
        throw 'Error updating profile: $e';
      }
    }
  }

  // Get Total User Count
  Future<int> getUserCount() async {
    try {
      final AggregateQuerySnapshot snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0; 
    }
  }

  // Get All Users stream
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include doc ID
        return data;
      }).toList();
    });
  }

  // Stream of Auth Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
