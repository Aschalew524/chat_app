import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;            
  final String username;       
  final String email;          
  final String? profileImage;  
  final bool isOnline;         
  final Timestamp lastSeen;    

  UserModel ({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImage,
    this.isOnline = false,
    required this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      profileImage: map['profileImage'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}
