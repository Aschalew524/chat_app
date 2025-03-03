import 'package:chat_app/widgets/Textfield.dart';
import 'package:chat_app/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class signupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body:Padding(padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: TextEditingController(), hintText: "Email"),
            SizedBox(height: 10),
            CustomTextField(controller: TextEditingController(), hintText: "Password"),
            SizedBox(height: 10),
            CustomTextField(controller: TextEditingController(), hintText: "Confirm Password"),
            SizedBox(height: 20),
            CustomButton(text: "Sign Up", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}