import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_project/authentication/cloud_firestore_methods.dart';
import 'package:hackathon_project/authentication/user_details_model.dart';
import 'package:hackathon_project/widgets/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SharedPreferences? pref;
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();
  String currentPage = 'My Profile';
  String phoneNumber = "";
  String email = "";
  String address = "";
  String? imageUrl;
  bool isEditing = false;
  late ImageSource selectedImageSource;
  String name = "";

  Future<void> getNameFromFirestore() async {
    UserDetailsModel userDetails = await cloudFirestoreClass.getNameAndAddress();
    setState(() {
      name = userDetails.name;
      print("Name: $name");
    });
  }

  @override
  void initState() {
    getNameFromFirestore(); // Call getNameFromFirestore() here
    super.initState();
    init();
    loadPref();
    _loadUserData();
  }


  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      email = user?.email ?? '';
      phoneNumber = user?.phoneNumber ?? '';
    });
  }

  void init() async {
    pref = await SharedPreferences.getInstance();
    setState(() {});
  }

  void loadPref() {
    address = pref?.getString('address') ?? '';
    imageUrl = pref?.getString('imageUrl');
  }

  void selectImageFromSource(ImageSource source) async {
    final pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      // Upload the selected image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_images');
      final uploadTask = storageRef.putFile(File(pickedImage.path));
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded image
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });

        // Save the image URL to shared preferences
        if (pref != null) {
          pref!.setString('imageUrl', downloadUrl);
        }
      }
    }
  }


  void showImageSourceSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Camera"),
                  onTap: () {
                    Navigator.of(context).pop();
                    selectImageFromSource(ImageSource.camera);
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    selectImageFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 162, 204),
        automaticallyImplyLeading: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: isEditing
                      ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showImageSourceSelectionDialog();
                    },
                  )
                      : null,
                ),

                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: name, // Set the initialValue to the fetched name
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        name = value;
                      }
                    });
                  },
                ),

                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: phoneNumber.isNotEmpty ? phoneNumber : email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: phoneNumber.isNotEmpty ? 'Phone Number' : 'Email',
                  ),
                  onChanged: (value) {
                    // Update phone number or email
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: address,
                  decoration: InputDecoration(
                    labelText: 'Address',
                  ),
                  onChanged: (value) {
                    setState(() {
                      address = value;
                    });
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: saveDataToFirestore,
                  child: Text("Save"),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 68, 243, 168), // Set the button color to yellow
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveDataToFirestore() async {
    if (pref != null) {
      pref!.setString('address', address);
    }
    UserDetailsModel user = UserDetailsModel(name: name);
    await cloudFirestoreClass.uploadNameAndAddressToDatabase(user: user);
  }
}


