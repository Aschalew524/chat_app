import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}