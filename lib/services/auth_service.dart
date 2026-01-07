import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Đăng ký thất bại';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Đăng nhập thất bại';
    }
  }

  Future<void> logout() async => await _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Future sendPasswordResetEmail(String email) async {}
}
