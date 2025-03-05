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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Chats",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[600]),
            onPressed: () {
              // Search functionality handled by search bar below
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.grey[600]),
            onPressed: () {
              _showNewChatDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
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
          // Search bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          // Chats list
          Expanded(
            child: _currentUser == null
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
                : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _conversationsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(color: Colors.blue),
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
                        
                        // Filter conversations based on search query
                        if (_searchQuery.isNotEmpty) {
                          conversations = conversations.where((conversation) {
                            UserModel? otherUser = conversation['otherUser'];
                            return otherUser != null && 
                                   otherUser.username.toLowerCase().contains(_searchQuery);
                          }).toList();
                        }
                        
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
                                    backgroundColor: Colors.blue,
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
                        
                        return ListView.separated(
                          itemCount: conversations.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[200],
                            indent: 72,
                          ),
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return _buildChatTile(conversation);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.chat, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel otherUser, String displayName) {
    bool hasValidImage = otherUser.profileImage != null && otherUser.profileImage!.isNotEmpty;
    
    if (hasValidImage) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(otherUser.profileImage!),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
        child: null,
      );
    } else {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      );
    }
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
    String lastMessageText = lastMessage?.text ?? 'Lorem ipsum dolor sit amet, consectetur. Tortor odio hac iaculis sit.';
    String timeText = _formatTimestamp(lastMessageTime);
    
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: _buildProfileAvatar(otherUser, displayName),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (unreadCount == 0)
              Icon(
                Icons.check,
                color: Colors.blue,
                size: 16,
              ),
            SizedBox(width: 8),
            Text(
              timeText,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  lastMessageText,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
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
    if (timestamp == null) return 'Yesterday';
    
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Return day name for recent days
        List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dateTime.weekday - 1];
      } else {
        return 'Dec 20, 2025';
      }
    } else if (difference.inHours > 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return 'Just now';
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
