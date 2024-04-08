import 'package:flutter/material.dart';
import 'package:hackathon_project/List/my_button.dart';
import 'package:hackathon_project/constants/color_theme.dart';

// ignore: must_be_immutable
class DialogBox extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;

  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  final Tcontroller;
  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controller,
    // ignore: non_constant_identifier_names
    required this.Tcontroller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: combinedColor,
      content: SizedBox(
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // get user input
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Add a medicine name",
                fillColor: Colors.white,
                filled: true,
              ),
            ),

            TextField(
              controller: Tcontroller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Add a time",
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            // buttons -> save + cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // save button
                MyButton(
                  text: "Cancel",
                  onPressed: onCancel,
                  col: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                MyButton(
                  text: "Save",
                  onPressed: onSave,
                  col: Color.fromARGB(255, 68, 243, 168),
                ),

                // cancel button
              ],
            ),
          ],
        ),
      ),
    );
  }
}
