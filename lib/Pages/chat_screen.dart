import 'package:chat_app/widgets/Textfield.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Align(
                  alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.grey[300] : Colors.blue[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Message $index"),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    hintText: "Enter message",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
