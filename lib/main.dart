import 'package:chat_app/pages/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      print('Firebase already initialized');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    // If it's a duplicate app error, try to get the existing app
    if (e.toString().contains('duplicate-app')) {
      try {
        Firebase.app();
        print('Using existing Firebase app');
      } catch (appError) {
        print('Error getting existing Firebase app: $appError');
      }
    }
  }
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

 



