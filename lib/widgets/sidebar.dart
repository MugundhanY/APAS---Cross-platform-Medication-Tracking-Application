import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/Screens/home_screen.dart';
import 'package:hackathon_project/Screens/opening_page.dart';
import 'package:hackathon_project/Screens/profile_page.dart';
import 'package:hackathon_project/authentication/google_sign_in.dart';
import 'package:hive/hive.dart';

class AppDrawer extends StatefulWidget {
  final String currentPage;

  const AppDrawer({Key? key, required this.currentPage}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, IconData> _buttonIcons = {
    'Home': Icons.home_rounded,
    'My Profile': Icons.person_rounded,
    'Text to speech settings': Icons.volume_up_rounded,
    'Logout': Icons.logout_rounded,
  };

  void deleteData() async {
    final box = await Hive.openBox('mybox');

    // Alternatively, delete all data in the box
    box.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color.fromARGB(255, 189, 211, 232),
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Image(
                image: const AssetImage("assets/applogo.jpg"),
              ),
            ),
            Column(
              children: [
                for (final buttonName in _buttonIcons.keys)
                  ListTile(
                    leading: Icon(
                      _buttonIcons[buttonName],
                      color: buttonName == widget.currentPage
                          ? Color.fromARGB(255, 68, 243,
                              168) // Highlight current page button
                          : Colors.black,
                    ),
                    title: Text(
                      buttonName,
                      style: TextStyle(
                        color: buttonName == widget.currentPage
                            ? Color.fromARGB(255, 68, 243,
                                168) // Highlight current page button
                            : Colors.black,
                      ),
                    ),
                    onTap: () async {
                      // Handle button tap here
                      // You can navigate to different pages or perform actions
                      Navigator.of(context)
                          .pop(); // Close the drawer before navigating

                      // Navigate to the corresponding page based on the button tapped
                      if (buttonName == 'Home') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => home()),
                        );
                      } else if (buttonName == 'My Profile') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      } else if (buttonName == 'Text to spe;ech settings') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AudioSettingsPage()),
                        );
                      } else if (buttonName == 'Logout') {
                        deleteData();
                        await FirebaseAuth.instance.signOut();
                        AuthService().signOutWithGoogle();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
