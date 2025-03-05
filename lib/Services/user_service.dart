import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save user: $e");
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch user: $e");
    }
  }
}
