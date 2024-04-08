import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/authentication/cloud_firestore_methods.dart';
import 'package:hackathon_project/authentication/user_details_model.dart';
import 'package:hackathon_project/on_boarding_screen/on_boarding_screen.dart';

import '../constants/color_theme.dart';

class NamePhone extends StatefulWidget {
  const NamePhone({Key? key}) : super(key: key);

  @override
  State<NamePhone> createState() => _NamePhoneState();
}

class _NamePhoneState extends State<NamePhone> {
  final _nameController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0, // Remove the default elevation
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: lightBackgroundaGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter Your Name',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 10),
          // email textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                hintText: 'Name',
                fillColor: Colors.grey[200],
                filled: true,
                prefixIcon: Icon(Icons.person_2_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          MaterialButton(
            onPressed: () async {
              UserDetailsModel user = UserDetailsModel(name: _nameController.text);
              await cloudFirestoreClass.uploadNameAndAddressToDatabase(user: user);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                return const OnBoardingScreen();
              }));
            },
            child: Text('Continue'),
            color: Color.fromARGB(255, 68, 243, 168),
          )
        ],
      ),
        ),
    ],
    ),
    );
  }
}
