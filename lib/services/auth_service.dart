import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Anonymous login (1차 개발용)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous login error: $e');
      return null;
    }
  }

  // TODO: 카카오 로그인 (2차 개발)
  // Future<UserCredential?> signInWithKakao() async { ... }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
