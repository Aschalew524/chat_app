import 'package:flutter/material.dart';
import 'package:chat_app/Services/auth_services.dart';
import 'package:chat_app/Services/chat_service.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsListPage extends StatefulWidget {
  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  User? _currentUser;
  Stream<List<Map<String, dynamic>>>? _conversationsStream;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _conversationsStream = _chatService.getUserConversations(_currentUser!.uid);
    }
    setState(() {});
  }

  void _signOut() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _openChat(String chatId, String chatName, String receiverId) {
    // Mark messages as read when opening chat
    if (_currentUser != null) {
      _chatService.markMessagesAsRead(chatId, _currentUser!.uid);
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatId: chatId,
          chatName: chatName,
          receiverId: receiverId,
        ),
      ),
    );
  }

  String _getUserName() {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    } else if (_currentUser?.email != null) {
      // Extract name from email (before @ symbol)
      String email = _currentUser!.email!;
      String name = email.split('@')[0];
      // Capitalize first letter
      return name[0].toUpperCase() + name.substring(1);
    } else {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with user info
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.brown,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back, ${_getUserName()}!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Chats list
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _currentUser == null
                  ? Center(child: CircularProgressIndicator(color: Colors.brown))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _conversationsStream,
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
                                  'Error loading chats',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        List<Map<String, dynamic>> conversations = snapshot.data ?? [];
                        
                        if (conversations.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.forum_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'No Chats Yet',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'You haven\'t started any conversations yet.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap the + button below to start chatting!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () => _showNewChatDialog(),
                                  icon: Icon(Icons.add_comment, color: Colors.white),
                                  label: Text(
                                    'Start New Chat',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return _buildChatTile(conversation);
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog();
        },
        backgroundColor: Colors.brown,
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> conversation) {
    UserModel? otherUser = conversation['otherUser'];
    MessageModel? lastMessage = conversation['lastMessage'];
    int unreadCount = conversation['unreadCount'] ?? 0;
    Timestamp? lastMessageTime = conversation['lastMessageTime'];
    
    if (otherUser == null) {
      return SizedBox.shrink(); // Skip if user data is not available
    }
    
    String displayName = otherUser.username;
    String lastMessageText = lastMessage?.text ?? 'No messages yet';
    String timeText = _formatTimestamp(lastMessageTime);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.brown[100],
              backgroundImage: otherUser.profileImage != null 
                  ? NetworkImage(otherUser.profileImage!) 
                  : null,
              child: otherUser.profileImage == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            if (otherUser.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              timeText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                lastMessageText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(
          conversation['chatId'],
          displayName,
          otherUser.uid,
        ),
      ),
    );
  }
  
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showNewChatDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the email of the person you want to chat with:'),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _startNewChat(emailController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: Text('Start Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _startNewChat(String email) async {
    if (email.isEmpty || _currentUser == null) {
      Navigator.pop(context);
      return;
    }

    try {
      // Find user by email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found with email: $email'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      UserModel otherUser = UserModel.fromMap(
        userQuery.docs.first.data() as Map<String, dynamic>,
      );

      // Don't allow chatting with yourself
      if (otherUser.uid == _currentUser!.uid) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You cannot start a chat with yourself'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get or create chat
      String chatId = await _chatService.getOrCreateChat(_currentUser!.uid, otherUser.uid);
      
      Navigator.pop(context);
      _openChat(chatId, otherUser.username, otherUser.uid);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
