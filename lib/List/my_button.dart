import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  final String text;
  final Color col;
  VoidCallback onPressed;

  MyButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.col});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: col,
      child: Text(text),
    );
  }
}
