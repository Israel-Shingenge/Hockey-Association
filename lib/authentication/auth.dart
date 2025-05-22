import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    
    await userCredential.user?.updateDisplayName(fullName);

    
    await _saveUserToFirestore(userCredential.user!, fullName);

    return userCredential;
  }

  
  Future<UserCredential?> signInWithGoogle() async {
    try {
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        
        final displayName = user.displayName ?? '';
        final names = displayName.split(' ');
        final firstName = names.isNotEmpty ? names[0] : '';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        
        final userData = {
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'photoURL': user.photoURL ?? '',
          'lastSignIn': FieldValue.serverTimestamp(),
        };

        
        await _firestore.collection('Users').doc(user.uid).set(
              userData,
              SetOptions(merge: true), 
            );
      }

      return userCredential;
    } catch (e) {
      rethrow; 
    }
  }

  
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

  
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); 
  }
}
