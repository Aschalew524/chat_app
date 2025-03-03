import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? _user; // Declare the _user variable

  User? get user {
    return _user; // Return the stored user
  }

  Future<bool?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        print('User signed in!');
        _user = userCredential.user; // Store the user
        return true;
      }
      return false; // Explicitly return false if userCredential.user is null
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
