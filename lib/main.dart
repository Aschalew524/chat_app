// Import necessary packages
import 'package:chat_app/Pages/settings_screen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/Pages/signup.dart';
import 'package:chat_app/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen() //SettingsScreen()//HomeScreen()//ProfileScreen()//ChatScreen()////,
    );
  }
}

// Reusable Button Widget


// Reusable Text Input Field

// Authentication Screen


// Home Screen


// Chat Screen

// Profile Screen


// Settings Screen

