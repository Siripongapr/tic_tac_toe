import 'package:flutter/material.dart';

class XO extends StatelessWidget {
  const XO({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: text == 'X' ? Colors.blue : Colors.green));
  }
}
