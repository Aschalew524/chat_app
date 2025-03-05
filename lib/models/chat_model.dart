import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? fileUrl;
  final Timestamp timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.type = MessageType.text,
    this.fileUrl,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.index,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] != null ? MessageType.values[map['type']] : MessageType.text,
      fileUrl: map['fileUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
