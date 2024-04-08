import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/Phone.dart';
import 'package:hackathon_project/Screens/opening_page.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/Screens/phone_sign_up.dart';
import 'package:hackathon_project/Screens/sign_in_screen.dart';
import 'package:hackathon_project/authentication/authentication_methods.dart';
import 'package:hackathon_project/constants/constants.dart';
import 'package:hackathon_project/authentication/google_sign_in.dart';
import 'package:hackathon_project/constants/utils.dart';
import 'package:hackathon_project/on_boarding_screen/on_boarding_screen.dart';
import 'package:hackathon_project/widgets/custom_main_button.dart';
import 'package:hackathon_project/widgets/sign_in_buttons.dart';
import 'package:hackathon_project/widgets/text_field_widget.dart';
import 'package:http/http.dart' as http;

import '../constants/color_theme.dart';
String link = "https://1c45-2406-7400-bb-5981-8dff-a932-bd87-c04.ngrok-free.app/";
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthenticationMethods authenticationMethods = AuthenticationMethods();

  bool isLoading = false;
  bool vertical = false;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
  }

  String getCurrentUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      print(uid);
      return uid;
    } else {
      // User is not logged in
      return '';
    }
  }
  Future<void> sendUIDToWebsite(String uid) async {
    var url = link+'api/create_user?user_id=$uid'; // Replace with the website's API endpoint

    // Create the request headers (if required)
    /*Map<String, String> headers = {
      // Add any necessary headers, such as authentication tokens
      'Content-Type': 'application/json', // Example header
    };

    // Create the request body
    Map<String, dynamic> requestBody = {
      'uid': uid,
    };

     */

    // Send the POST request
    var response = await http.post(
      Uri.parse(url),
      //headers: headers,
      //body: requestBody,
    );


    // Check the response status
    if (response.statusCode == 200) {
      // Request successful
      print('UID sent to the website');
    } else {
      // Error in the request
      print('Error sending UID: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          elevation: 0, // Remove the default elevation
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LoginPage();
                    },
                  ),
                );
              })),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: lightBackgroundaGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                /*Image.asset(
                  'assets/applogo.jpg',
                  height: screenSize.height * 0.15,
                ),*/
                //SizedBox(height: screenSize.height * 0.0626),
                Text(
                  "Sign-Up",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 33,
                      color: Color.fromARGB(255, 0, 3, 16),),
                ),
                SizedBox(height: screenSize.height * 0.0313),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.073),
                  child: TextFieldWidget(
                    title: "Name",
                    controller: nameController,
                    obscureText: false,
                    hintText: "Enter your name",
                    ic: Icon(Icons.person_outline_rounded),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01252),

                // password textfield
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.073),
                  child: TextFieldWidget(
                    title: "Email",
                    controller: emailController,
                    obscureText: false,
                    hintText: "Enter your email",
                    ic: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01252),

                // password textfield
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.073),
                  child: TextFieldWidget(
                    title: "Password",
                    controller: passwordController,
                    obscureText: true,
                    hintText: "Enter your password",
                    ic: Icon(Icons.fingerprint),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01252),

                // password textfield
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.073),
                  child: TextFieldWidget(
                    title: "Confirm password",
                    controller: confirmPasswordController,
                    obscureText: true,
                    hintText: "Re-enter your password",
                    ic: Icon(Icons.fingerprint),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.0313),

                // sign in button
                Align(
                  alignment: Alignment.center,
                  child: CustomMainButton(
                    color: Color.fromARGB(255, 68, 243, 168),
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      String output = await authenticationMethods.signUpUser(
                          name: nameController.text,
                          confirmPassword: confirmPasswordController.text,
                          email: emailController.text,
                          password: passwordController.text);
                      setState(() {
                        isLoading = false;
                      });
                      if (output == "success") {
                        // ignore: use_build_context_synchronously
                        String uid = getCurrentUserId();
                        sendUIDToWebsite(uid);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const OnBoardingScreen();
                        }));
                      } else {
                        // ignore: use_build_context_synchronously
                        Utils().showSnackBar(context: context, content: output);
                      }
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        letterSpacing: 0.6,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.0626),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenSize.height * 0.0626),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    signInButtons(
                      onTap: () async {
                        String output = await AuthService().signUpwithGoogle();
                        if (output == "success") {
                          // Obtain the current user from Firebase Authentication
                          String uid = getCurrentUserId();
                          sendUIDToWebsite(uid);
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const OnBoardingScreen();
                          }));
                        } else {
                          // ignore: use_build_context_synchronously
                          Utils()
                              .showSnackBar(context: context, content: output);
                        }
                      },
                      imagePath: googleLogo,
                    ),
                    signInButtons(
                        onTap: () async {
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                                return const MyPhoneSignUp();
                              }));
                        },
                        imagePath: phone),
                  ],
                ),
                SizedBox(height: screenSize.height * 0.0626),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const SignInScreen();
                        }));
                      },
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenSize.height * 0.0626),
              ],
            ),
          ),
        ),
      ),
          ),
          ],
          ),
    );
  }
}
