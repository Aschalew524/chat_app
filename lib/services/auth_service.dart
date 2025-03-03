import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get user => _firebaseAuth.currentUser;

  Future<bool?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        print('✅ User signed in: ${userCredential.user!.email}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error: $e'); // Debugging error message
      return false;
    }
  }
}
