import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/home_screen.dart';
import 'package:hackathon_project/Screens/opening_page.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/constants/color_theme.dart';
import 'package:hackathon_project/on_boarding_screen/on_boarding_screen.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  // Obtain a list of the available cameras on the device.
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ignore: unused_local_variable
  var box = await Hive.openBox('mybox');
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "",
            authDomain: "",
            databaseURL:
                "",
            projectId: "",
            storageBucket: "",
            messagingSenderId: "",
            appId: "",
            measurementId: ""));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const project1());
}

// ignore: camel_case_types
class project1 extends StatelessWidget {
  const project1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Medi Mind",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if (user.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          } else if (user.hasData) {
            return const home();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
