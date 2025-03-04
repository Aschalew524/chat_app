import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;            
  final String username;       
  final String email;          
  final String? profileImage;  
  final bool isOnline;         
  final Timestamp lastSeen;    

  User({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImage,
    this.isOnline = false,
    required this.lastSeen,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
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
