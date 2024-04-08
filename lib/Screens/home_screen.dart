import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hackathon_project/List/database.dart';
import 'package:hackathon_project/List/dialog_box.dart';
import 'package:hackathon_project/List/todo_tile.dart';
import 'package:hackathon_project/Screens/alert_dialog.dart';
import 'package:hackathon_project/Screens/camera.dart';
import 'package:hackathon_project/Screens/profile.dart';
import 'package:hackathon_project/constants/utils.dart';
import 'package:hackathon_project/widgets/sidebar.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/color_theme.dart';

String link = "https://1c45-2406-7400-bb-5981-8dff-a932-bd87-c04.ngrok-free.app/";
// ignore: camel_case_types
class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

// ignore: camel_case_types
class _homeState extends State<home> {
  List<dynamic> _filteredList = [];
  final _searchController = TextEditingController();
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();
  final String currentPage = 'Home';
  @override
  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    _filteredList = db.toDoList;
    _searchController.addListener(() {
      setState(() {
        _filteredList = db.toDoList
            .where((task) => task[0]
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // ignore: non_constant_identifier_names
  final _Tcontroller = TextEditingController();
  final _medicineNamecontroller = TextEditingController();

  // ignore: non_constant_identifier_names
  final _dosageTimeController = TextEditingController();

  // checkbox was tapped

  void _filterList(String searchQuery) {
    if (searchQuery.isEmpty) {
      setState(() {
        _filteredList = db.toDoList;
      });
      return;
    }

    final List<dynamic> filteredList = [];
    for (var element in db.toDoList) {
      if (element[0].toLowerCase().contains(searchQuery.toLowerCase())) {
        filteredList.add(element);
      }
    }

    setState(() {
      _filteredList = filteredList;
    });
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, _Tcontroller.text]);
      _controller.clear();
      _Tcontroller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          Tcontroller: _Tcontroller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> sendJsonToServer(String string1, String string2, String userId) async {
    // Create a map with the two strings
    Map<String, dynamic> jsonData = {
       string1 : string2
    };

    Map<String, dynamic> Data = {
      "data" : jsonData
    };
    // Convert the map to JSON string
    String jsonString = jsonEncode(Data);

    // Set the headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Make the HTTP POST request
    Uri url = Uri.parse(link+'api/update_med_data?user_id=$userId');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: jsonString,
    );

    // Handle the response
    if (response.statusCode == 200) {
      print('JSON sent successfully!');
    } else {
      print('Error sending JSON: ${response.statusCode}');
    }
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

  void saveTask() {
    setState(() async{
      String userId = getCurrentUserId();
      await sendJsonToServer(_medicineNamecontroller.text, _dosageTimeController.text, userId);
      _medicineNamecontroller.clear();
      _dosageTimeController.clear();
    });
    Navigator.of(context).pop();
  }

  // create a new task
  void createTask() {
    showDialog(
      context: context,
      builder: (context) {
        return alertDialog(
          medicineNamecontroller: _medicineNamecontroller,
          dosageTimeController: _dosageTimeController,
          onSave: saveTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                //<-- SEE HERE
                child: const Text('No',
                    style: TextStyle(
                      color: Colors.red,
                    )),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => exit(0),
                    ),
                  );
                },
                child: const Text('Yes',
                    style: TextStyle(
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawer: AppDrawer(currentPage: currentPage),
        appBar: AppBar(
          elevation: 0, // Remove the default elevation
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          /*title: const Text(
            "Med Search",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

           */
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
              onPressed: createNewTask,
            ),
            IconButton(
              icon: const Icon(
                Icons.upload_rounded,
                color: Colors.white,
              ),
              onPressed: createTask,
            ),
            /*IconButton(
              icon: const Icon(
                Icons.person_2_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                // handle more button press
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const Profile();
                    },
                  ),
                );
              },
            ),

             */
          ],
        ),
        body:Stack(
          children: [Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: lightBackgroundaGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.02,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: screenSize.height*0.11,
                  ),
                  searchBox(),
                        Container(
                          margin: EdgeInsets.only(
                            top: screenSize.height * 0.025,
                            bottom: 0,
                          ),
                          child: const Text(
                            'Medicine List',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Positioned(
              top: screenSize.height * 0.15,
              // adjust this value to match the height of your text
              left: 0,
              right: 0,
              bottom: 0,
              child: ListView.builder(
                itemCount: _filteredList.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                    taskName: _filteredList[index][0],
                    // taskCompleted: db.toDoList[index][1],
                    timerr: db.toDoList[index][1],
                    //onChanged: (value) => checkBoxChanged(value, index),
                    deleteFunction: (context) => deleteTask(index),
                  );
                },
              ),
            ),
          ],
        ),
    ),
        ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 68, 243, 168),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraView(),
              ),
            );
          },
          child: const Icon(Icons.camera_alt_rounded),
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: _filterList,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}

const Color tdRed = Color(0xFFDA4040);
const Color tdBlue = Color(0xFF5F52EE);

const Color tdBlack = Color(0xFF3A3A3A);
const Color tdGrey = Color(0xFF717171);

const Color tdBGColor = Color(0xFFEEEFF5);
