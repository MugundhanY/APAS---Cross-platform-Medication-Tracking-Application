import 'package:flutter/material.dart';
import 'package:hackathon_project/constants/utils.dart';

// ignore: camel_case_types
class signInButtons extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;

  const signInButtons({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.network(
          imagePath,
          height: screenSize.height * 0.05,
        ),
      ),
    );
  }
}
