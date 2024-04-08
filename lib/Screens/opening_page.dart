import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/sign_in_screen.dart';
import 'package:hackathon_project/Screens/sign_up_screen.dart';
import 'package:hackathon_project/constants/utils.dart';

import '../constants/color_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0),
        reverseCurve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 187, 212, 232),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: screenSize.height * 0.05),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Image(image: const AssetImage("assets/applogo.jpg"), height: screenSize.height * 0.6),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text("APAS", style: Theme.of(context).textTheme.displaySmall),
                  ),
                  SizedBox(height: screenSize.height * 0.00025),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Automate your inventory with AI",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.05),
              SlideTransition(
                position: _slideAnimation,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return const SignInScreen();
                          }));
                        },
                        child: Text("login".toUpperCase()),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return const SignUpScreen();
                          }));
                        },
                        child: Text("signup".toUpperCase()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
