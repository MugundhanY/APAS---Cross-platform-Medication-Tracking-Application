import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathon_project/authentication/cloud_firestore_methods.dart';
import 'package:hackathon_project/authentication/user_details_model.dart';

class AuthenticationMethods {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();

  Future<String> signUpUser(
      {required String name,
      required String confirmPassword,
      required String email,
      required String password}) async {
    name.trim();
    email.trim();
    confirmPassword.trim();
    password.trim();
    String output = "Something went wrong";

    if (name != "" && confirmPassword != "" && email != "" && password != "") {
      output = "success";
      if (password != confirmPassword) {
        output = "Password do not match";
      } else {
        try {
          await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);
          UserDetailsModel user = UserDetailsModel(name: name);
          await cloudFirestoreClass.uploadNameAndAddressToDatabase(user: user);
          output = "success";
        } on FirebaseAuthException catch (e) {
          output = e.message.toString();
        }
      }
    } else {
      output = "Please fill up all the fields.";
    }
    return output;
  }

  Future<String> signInUser(
      {required String email, required String password}) async {
    email.trim();
    password.trim();
    String output = "Something went wrong";
    if (email != "" && password != "") {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        output = "success";
      } on FirebaseAuthException catch (e) {
        output = e.message.toString();
      }
    } else {
      output = "Please fill up all the fields.";
    }
    return output;
  }
}
