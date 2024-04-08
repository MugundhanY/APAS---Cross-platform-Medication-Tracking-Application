import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/Screens/home_screen.dart';
import 'package:hackathon_project/Screens/name_phone_getter.dart';
import 'package:hackathon_project/Screens/opening_page.dart';
import 'package:hackathon_project/authentication/authentication_methods.dart';
import 'package:hackathon_project/constants/utils.dart';
import 'package:hackathon_project/on_boarding_screen/on_boarding_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

String link = "https://1c45-2406-7400-bb-5981-8dff-a932-bd87-c04.ngrok-free.app/";
String phoneNumber = "";
class MyPhoneSignUp extends StatefulWidget {
  const MyPhoneSignUp({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<MyPhoneSignUp> createState() => _MyPhoneSignUpState();
}

class _MyPhoneSignUpState extends State<MyPhoneSignUp> {
  TextEditingController countryController = TextEditingController();
  AuthenticationMethods authenticationMethods = AuthenticationMethods();

  var phone = "";
  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+91";
    super.initState();
  }

 Widget build(BuildContext context) {
      Size screenSize= Utils().getScreenSize();
      final ThemeData theme = Theme.of(context);
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 189, 211, 232),
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
        body: SingleChildScrollView(
      child: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Image.asset('assets/applogo.jpg', height: screenSize.width*0.4, width: screenSize.width*0.4),
          color: Color.fromARGB(255, 189, 211, 232),

        height: screenSize.height*0.6,
          width: screenSize.width,
      ),
        SizedBox(
          height: screenSize.height*0.05,
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*textWidget(text: AppConstants.helloNiceToMeetYou),
                textWidget(
                    text: AppConstants.enterMobileNumber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),


                 */
                const SizedBox(
                  height: 40,
                ),
                //!otp box
                Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 3,
                        blurRadius: 3,
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: countryController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Text(
                          "|",
                          style: TextStyle(fontSize: 33, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              onChanged: (value){
                                phone = value;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Phone",
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 68, 243, 168),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async{
                          phoneNumber = countryController.text+phone;
                          await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: '${countryController.text+phone}',
                              verificationCompleted: (PhoneAuthCredential credential){},
                              verificationFailed:  (FirebaseAuthException e) {},
                              codeSent: (String verificationId, int? resendToken) {
                                MyPhoneSignUp.verify = verificationId;

                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                  return const MyVerifySignUp();
                                }));
                              },
                              codeAutoRetrievalTimeout: (String verificationId) {}
                          );
                        },
                        child: Text("Send the code")),
                  )
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

class MyVerifySignUp extends StatefulWidget {
  const MyVerifySignUp({Key? key}) : super(key: key);

  @override
  State<MyVerifySignUp> createState() => _MyVerifySignUpState();
}

class _MyVerifySignUpState extends State<MyVerifySignUp> {
  final FirebaseAuth auth = FirebaseAuth.instance;

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
    Size screenSize= Utils().getScreenSize();
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.green.shade200,
      ),
    );

    var code ="";
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 162, 204),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return const MyPhoneSignUp();
            }));
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img.png',
                height: screenSize.height * 0.3,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellow.shade900),
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                 defaultPinTheme: defaultPinTheme,
                 focusedPinTheme: focusedPinTheme,
                 submittedPinTheme: submittedPinTheme,

                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    onPressed: () async{
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider
                            .credential(
                            verificationId: MyPhoneSignUp.verify, smsCode: code);
                        await auth.signInWithCredential(credential);
                        String uid = getCurrentUserId();
                        sendUIDToWebsite(uid);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                          return const NamePhone();
                        }));
                      }
                      catch(e){
                        Utils().showSnackBar(
                            context: context, content: "Wrong OTP");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 68, 243, 168),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Verify Phone Number")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
