import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/Phone.dart';
import 'package:hackathon_project/Screens/forget_password.dart';
import 'package:hackathon_project/Screens/home_screen.dart';
import 'package:hackathon_project/Screens/opening_page.dart';
import 'package:hackathon_project/Screens/sign_up_screen.dart';
import 'package:hackathon_project/authentication/authentication_methods.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/constants/constants.dart';
import 'package:hackathon_project/authentication/google_sign_in.dart';
import 'package:hackathon_project/constants/utils.dart';
import 'package:hackathon_project/widgets/custom_main_button.dart';
import 'package:hackathon_project/widgets/sign_in_buttons.dart';
import 'package:hackathon_project/widgets/text_field_widget.dart';

import '../constants/color_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: lightBackgroundaGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
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

                      // welcome back, you've been missed!
                      Text(
                        "Sign-In",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 33,
                          color: Color.fromARGB(255, 0, 3, 16),
                        ),
                      ),

                      SizedBox(height: screenSize.height * 0.0313),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.073),
                        // username textfield
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

                      // forgot password?
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.073),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ForgotPasswordPage();
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ],
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
                            Future.delayed(const Duration(seconds: 1));
                            String output =
                                await authenticationMethods.signInUser(
                                    email: emailController.text,
                                    password: passwordController.text);
                            setState(() {
                              isLoading = false;
                            });
                            setState(() {
                              if (output == "success") {
                                //functions
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const home();
                                }));
                              } else {
                                Utils().showSnackBar(
                                    context: context, content: output);
                              }
                            });
                          },
                          child: const Text(
                            "Sign In",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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
                                String output =
                                    await AuthService().signUpwithGoogle();
                                if (output == "success") {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const home();
                                  }));
                                } else {
                                  // ignore: use_build_context_synchronously
                                  Utils().showSnackBar(
                                      context: context, content: output);
                                }
                              },
                              imagePath: googleLogo),
                          signInButtons(
                              onTap: () async {
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const MyPhone();
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
                            'Not a member?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return const SignUpScreen();
                              }));
                            },
                            child: const Text(
                              'Register now',
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
