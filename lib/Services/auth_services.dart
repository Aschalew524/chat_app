import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ensure Firebase is initialized
  Future<void> _ensureInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        print('Firebase not initialized, initializing now...');
        // This should not happen if main.dart is properly configured
        throw Exception('Firebase not initialized. Please restart the app.');
      }
    } catch (e) {
      print('Firebase initialization check error: $e');
      throw Exception('Firebase initialization error: $e');
    }
  }

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      await _ensureInitialized();
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Signup successful: ${result.user?.email}");
      return result.user;
    } catch (e) {
      print("Signup Error: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            print("The password provided is too weak.");
            break;
          case 'email-already-in-use':
            print("An account already exists for that email.");
            break;
          case 'invalid-email':
            print("The email address is invalid.");
            break;
          case 'operation-not-allowed':
            print("Email/password accounts are not enabled.");
            break;
          default:
            print("Signup failed: ${e.message}");
        }
      }
      return null;
    }
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      await _ensureInitialized();
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Signin successful: ${result.user?.email}");
      return result.user;
    } catch (e) {
      print("Signin Error: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            print("No user found for that email.");
            break;
          case 'wrong-password':
            print("Wrong password provided.");
            break;
          case 'invalid-email':
            print("The email address is invalid.");
            break;
          case 'user-disabled':
            print("This user account has been disabled.");
            break;
          case 'too-many-requests':
            print("Too many requests. Try again later.");
            break;
          default:
            print("Signin failed: ${e.message}");
        }
      }
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _auth.signOut();
      print("Signout successful");
    } catch (e) {
      print("Signout Error: $e");
    }
  }
}
