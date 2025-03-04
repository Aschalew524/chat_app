import 'package:flutter/material.dart';
import 'package:chat_app/Services/auth_services.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatsListPage extends StatefulWidget {
  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  // Sample chat data - in a real app, this would come from Firebase
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'John Doe',
      'lastMessage': 'Hey, how are you doing?',
      'timestamp': '2:30 PM',
      'unreadCount': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'lastMessage': 'The meeting is scheduled for tomorrow',
      'timestamp': '1:45 PM',
      'unreadCount': 0,
      'isOnline': false,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'lastMessage': 'Thanks for the help!',
      'timestamp': '12:20 PM',
      'unreadCount': 1,
      'isOnline': true,
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'lastMessage': 'Can you send me the files?',
      'timestamp': '11:15 AM',
      'unreadCount': 0,
      'isOnline': false,
    },
    {
      'id': '5',
      'name': 'David Brown',
      'lastMessage': 'Great work on the project!',
      'timestamp': 'Yesterday',
      'unreadCount': 0,
      'isOnline': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  void _signOut() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _openChat(String chatId, String chatName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatId: chatId,
          chatName: chatName,
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
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _buildChatTile(chat);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement new chat functionality
        },
        backgroundColor: Colors.brown,
        child: Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
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
              child: Text(
                chat['name'][0].toUpperCase(),
                style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (chat['isOnline'])
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
                chat['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              chat['timestamp'],
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
                chat['lastMessage'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat['unreadCount'] > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(chat['id'], chat['name']),
      ),
    );
  }
}
