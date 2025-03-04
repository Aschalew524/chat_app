import 'package:flutter/material.dart';
import 'package:chat_app/Services/auth_services.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signOut() async {
    try {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: const Text('Profile editing feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account deletion feature coming soon!')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(color: Colors.brown),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings page coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: () {
                      // Implement profile picture change
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile picture change coming soon!')),
                      );
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: _currentUser?.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    _currentUser!.photoURL!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.brown,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.brown,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    _getUserName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // User Email
                  Text(
                    _currentUser?.email ?? 'No email',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: Icon(Icons.edit, color: Colors.brown),
                    label: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.brown),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Profile Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Account Information Section
                  _buildSection(
                    title: 'Account Information',
                    children: [
                      _buildProfileTile(
                        icon: Icons.person,
                        title: 'Display Name',
                        subtitle: _getUserName(),
                        onTap: () {
                          // Implement name change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Name change coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: _currentUser?.email ?? 'No email',
                        onTap: () {
                          // Implement email change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Email change coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.phone,
                        title: 'Phone Number',
                        subtitle: _currentUser?.phoneNumber ?? 'Not set',
                        onTap: () {
                          // Implement phone number change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Phone number change coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.calendar_today,
                        title: 'Member Since',
                        subtitle: _currentUser?.metadata.creationTime != null
                            ? '${_currentUser!.metadata.creationTime!.day}/${_currentUser!.metadata.creationTime!.month}/${_currentUser!.metadata.creationTime!.year}'
                            : 'Unknown',
                        onTap: null,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Settings Section
                  _buildSection(
                    title: 'Settings',
                    children: [
                      _buildProfileTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Manage your notifications',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notifications settings coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.security,
                        title: 'Privacy & Security',
                        subtitle: 'Manage your privacy settings',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Privacy settings coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Language settings coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.dark_mode,
                        title: 'Dark Mode',
                        subtitle: 'Off',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Dark mode coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Support Section
                  _buildSection(
                    title: 'Support',
                    children: [
                      _buildProfileTile(
                        icon: Icons.help,
                        title: 'Help & Support',
                        subtitle: 'Get help with the app',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Help & support coming soon!')),
                          );
                        },
                      ),
                      _buildProfileTile(
                        icon: Icons.info,
                        title: 'About',
                        subtitle: 'App version 1.0.0',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('About page coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Danger Zone
                  _buildSection(
                    title: 'Danger Zone',
                    children: [
                      _buildProfileTile(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account',
                        onTap: _showDeleteAccountDialog,
                        isDestructive: true,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.brown,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            )
          : null,
      onTap: onTap,
    );
  }
} 