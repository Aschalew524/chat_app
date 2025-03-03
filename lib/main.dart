import 'package:flutter/material.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/utils.dart'; // Firebase & GetIt setup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();  // Initialize Firebase
  await registerServices(); // Register GetIt services
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInScreen(), // Updated to correct sign-in screen
    );
  }
}
