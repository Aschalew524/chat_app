import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("User $index"),
            subtitle: Text("Last message from chat"),
            onTap: () {},
          );
        },
      ),
    );
  }
}