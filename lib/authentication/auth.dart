import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user and update display name
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update the display name with full name
    await userCredential.user?.updateDisplayName(fullName);

    // Save user info to Firestore
    await _saveUserToFirestore(userCredential.user!, fullName);

    return userCredential;
  }

  // Sign in with Google and save user data to Firestore
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // Extract first and last name if possible
        final displayName = user.displayName ?? '';
        final names = displayName.split(' ');
        final firstName = names.isNotEmpty ? names[0] : '';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        // Prepare data to save
        final userData = {
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'photoURL': user.photoURL ?? '',
          'lastSignIn': FieldValue.serverTimestamp(),
        };

        // Save or update the user document in Firestore
        await _firestore.collection('Users').doc(user.uid).set(
              userData,
              SetOptions(merge: true), // merge so it doesn't overwrite entire doc
            );
      }

      return userCredential;
    } catch (e) {
      rethrow; // Let caller handle errors
    }
  }

  // Save new user created with email/password to Firestore
  Future<void> _saveUserToFirestore(User user, String fullName) async {
    final names = fullName.split(' ');
    final firstName = names.isNotEmpty ? names[0] : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': user.email ?? '',
      'phone': user.phoneNumber ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Users').doc(user.uid).set(userData);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); // Also sign out from Google
  }
}
