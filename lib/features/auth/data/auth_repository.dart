import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('AuthRepo: Initializing GoogleSignIn...');
      final googleSignIn = GoogleSignIn(
        serverClientId: '1098453998984-imlq4ouggtdpsrkrep7ijqhm8thca9ak.apps.googleusercontent.com',
      );
      
      // Force account selection if needed, but first try to sign out to ensure the picker shows
      debugPrint('AuthRepo: Signing out of previous Google session...');
      await googleSignIn.signOut();
      
      debugPrint('AuthRepo: Calling googleSignIn.signIn()...');
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        debugPrint('AuthRepo: Google user obtained: ${googleUser.email}');
        final googleAuth = await googleUser.authentication;
        debugPrint('AuthRepo: Google auth obtained');
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        debugPrint('AuthRepo: Signing in with Firebase credential...');
        return await _auth.signInWithCredential(credential);
      } else {
        debugPrint('AuthRepo: googleUser is null (user likely cancelled)');
        throw Exception('Google sign in aborted by user');
      }
    } catch (e) {
      debugPrint('AuthRepo: Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
