import 'package:flutter/material.dart';
import 'package:chat_app/Services/auth_services.dart';
import 'package:chat_app/Services/chat_service.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  

class ChatPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  User? _currentUser;
  Stream<List<MessageModel>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _messagesStream = _chatService.getChatMessages(widget.chatId);
    }
    // Scroll to bottom when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && _currentUser != null) {
      String messageText = _messageController.text.trim();
      _messageController.clear();
      
      MessageModel message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _currentUser!.uid,
        receiverId: widget.receiverId,
        text: messageText,
        type: MessageType.text,
        timestamp: Timestamp.now(),
      );
      
      try {
        await _chatService.sendTextMessage(widget.chatId, message);
        _scrollToBottom();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.brown[100],
              child: Text(
                widget.chatName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.brown,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {
              // Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _currentUser == null
                  ? Center(child: CircularProgressIndicator(color: Colors.brown))
                  : StreamBuilder<List<MessageModel>>(
                      stream: _messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(color: Colors.brown),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading messages',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        List<MessageModel> messages = snapshot.data ?? [];
                        
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Messages Yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Start the conversation by sending a message!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Reverse the list to show newest messages at bottom
                        List<MessageModel> reversedMessages = messages.reversed.toList();
                        
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: reversedMessages.length,
                          itemBuilder: (context, index) {
                            final message = reversedMessages[index];
                            return _buildMessageBubble(message);
                          },
                        );
                      },
                    ),
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.brown),
                  onPressed: () {
                    // Implement file attachment
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.senderId == _currentUser?.uid;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.brown[100],
              child: Text(
                widget.chatName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe ? Colors.brown : Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image) ...[
                    if (message.fileUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.fileUrl!,
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: isMe ? Colors.white : Colors.brown,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (message.text.isNotEmpty && message.text != '📷 Image')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ] else ...[
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.brown[100],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.brown,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }
}
