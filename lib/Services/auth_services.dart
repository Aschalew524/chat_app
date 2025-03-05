
import 'package:chat_app/Services/user_service.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _ensureInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized. Please restart the app.');
      }
    } catch (e) {
      throw Exception('Firebase initialization error: $e');
    }
  }

  // Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload profile image from bytes (for web)
  Future<String?> _uploadProfileImageFromBytes(Uint8List imageBytes, String userId) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image from bytes: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUp(String email, String password, {String? username, File? profileImage, Uint8List? webImageBytes}) async {
    try {
      await _ensureInitialized();
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = result.user;
      if (firebaseUser == null) return null;

      // Upload profile image if provided
      String? profileImageUrl;
      if (kIsWeb && webImageBytes != null) {
        profileImageUrl = await _uploadProfileImageFromBytes(webImageBytes, firebaseUser.uid);
      } else if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(profileImage, firebaseUser.uid);
      }

      // Build your UserModel
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        username: username ?? email.split('@')[0], // Use email prefix if no username provided
        email: email,
        profileImage: profileImageUrl,
        isOnline: true,
        lastSeen: Timestamp.now(),
      );

      // Save user to Firestore via UserService
      await _userService.saveUser(newUser);

      print("Signup and Firestore save successful: ${newUser.email}");
      return newUser;

    } catch (e) {
      print("Signup Error: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            print('The password provided is too weak.');
            break;
          case 'email-already-in-use':
            print('The account already exists for that email.');
            break;
          case 'invalid-email':
            print('The email address is invalid.');
            break;
          default:
            print('Signup failed: ${e.message}');
        }
      }
      return null;
    }
  }

  // Sign in with email and password
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

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }
}
