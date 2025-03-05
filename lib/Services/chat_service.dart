import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get or create chat between two users
  Future<String> getOrCreateChat(String userId1, String userId2) async {
    // Create a consistent chat ID by sorting user IDs
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    String chatId = '${userIds[0]}_${userIds[1]}';
    
    // Check if chat exists
    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      // Create new chat document
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [userId1, userId2],
        'createdAt': Timestamp.now(),
        'lastMessage': null,
        'lastMessageTime': null,
      });
    }
    
    return chatId;
  }

  // Get user's conversations with last message info
  Stream<List<Map<String, dynamic>>> getUserConversations(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> conversations = [];
      
      try {
        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> chatData = doc.data();
            List<String> participants = List<String>.from(chatData['participants'] ?? []);
            
            // Get the other participant's ID
            String otherUserId = participants.firstWhere(
              (id) => id != userId,
              orElse: () => '',
            );
            
            if (otherUserId.isEmpty) continue;
            
            // Get other user's info
            UserModel? otherUser;
            try {
              DocumentSnapshot userDoc = await _firestore.collection('users').doc(otherUserId).get();
              if (userDoc.exists) {
                otherUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
              }
            } catch (e) {
              print('Error fetching user $otherUserId: $e');
              continue;
            }
            
            if (otherUser == null) continue;
            
            // Get last message
            MessageModel? lastMessage;
            try {
              QuerySnapshot lastMessageQuery = await _firestore
                  .collection('chats')
                  .doc(doc.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .get();
              
              if (lastMessageQuery.docs.isNotEmpty) {
                lastMessage = MessageModel.fromMap(
                  lastMessageQuery.docs.first.data() as Map<String, dynamic>,
                  lastMessageQuery.docs.first.id,
                );
              }
            } catch (e) {
              print('Error fetching last message for chat ${doc.id}: $e');
            }
            
            // Count unread messages
            int unreadCount = 0;
            try {
              QuerySnapshot unreadQuery = await _firestore
                  .collection('chats')
                  .doc(doc.id)
                  .collection('messages')
                  .where('receiverId', isEqualTo: userId)
                  .where('isRead', isEqualTo: false)
                  .get();
              unreadCount = unreadQuery.docs.length;
            } catch (e) {
              print('Error counting unread messages for chat ${doc.id}: $e');
            }
            
            conversations.add({
              'chatId': doc.id,
              'otherUser': otherUser,
              'lastMessage': lastMessage,
              'unreadCount': unreadCount,
              'lastMessageTime': chatData['lastMessageTime'],
            });
          } catch (e) {
            print('Error processing chat ${doc.id}: $e');
            continue;
          }
        }
        
        // Sort conversations by last message time
        conversations.sort((a, b) {
          Timestamp? timeA = a['lastMessageTime'];
          Timestamp? timeB = b['lastMessageTime'];
          
          if (timeA == null && timeB == null) return 0;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          
          return timeB.compareTo(timeA);
        });
        
      } catch (e) {
        print('Error in getUserConversations: $e');
        throw e;
      }
      
      return conversations;
    }).handleError((error) {
      print('Stream error in getUserConversations: $error');
      return <Map<String, dynamic>>[];
    });
  }

  // Send text message
  Future<void> sendTextMessage(String chatId, MessageModel message) async {
    // Add message to subcollection
    await _firestore.collection('chats').doc(chatId)
        .collection('messages')
        .add(message.toMap());
    
    // Update chat's last message info
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
    });
  }

  // Send image message
  Future<void> sendImageMessage(String chatId, File? file, Uint8List? webImage, String senderId, String receiverId) async {
    if (file == null && webImage == null) return;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('chat_images/$fileName');

    UploadTask uploadTask;
    if (kIsWeb && webImage != null) {
      uploadTask = ref.putData(webImage);
    } else if (file != null) {
      uploadTask = ref.putFile(file);
    } else {
      return;
    }

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Create message
    MessageModel message = MessageModel(
      id: _firestore.collection('chats').doc().id,
      senderId: senderId,
      receiverId: receiverId,
      text: '📷 Image',
      type: MessageType.image,
      fileUrl: downloadUrl,
      timestamp: Timestamp.now(),
    );

    // Add message to subcollection
    await _firestore.collection('chats').doc(chatId)
        .collection('messages')
        .add(message.toMap());
    
    // Update chat's last message info
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '📷 Image',
      'lastMessageTime': message.timestamp,
    });
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    QuerySnapshot unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    WriteBatch batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
