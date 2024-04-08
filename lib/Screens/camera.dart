import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hackathon_project/Screens/home_screen.dart';
import 'package:hackathon_project/constants/utils.dart';
import 'package:hackathon_project/widgets/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String a = "";
String link = "https://1c45-2406-7400-bb-5981-8dff-a932-bd87-c04.ngrok-free.app/";
String med = "Unable to find the medicine";
String ped = "Unable to access";
SharedPreferences? preferences;
class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isAutoOn = true;
  bool blurry = true;
  late AnimationController _animationController;
  Timer? _timer;
  final List<Offset> _dots = [];

  Future<void> _initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    // Set the camera description.
    setState(() {
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
    });
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the camera controller

    _initializeCamera();
    // Initialize the camera controller future

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final area = Rect.fromLTWH(
          0,
          MediaQuery.of(context).size.height / 12,
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 1.6);
      _addDot(area);
    });
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  Future<File> _savePicture(List<int> bytes) async {
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpeg';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  // adjust this value to your liking
  bool isShaking = false;

  void initSensorListener() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double deltaX = event.x;
      double deltaY = event.y;
      double deltaZ = event.z;
      double magnitude = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ;
      if (magnitude > 101.0 && magnitude < 97.0) {
        isShaking = true;
      } else {
        isShaking = false;
      }
    });
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

  void _toggleAuto() async {
    setState(() {
      _isAutoOn = !_isAutoOn;
      if (_isAutoOn) {
        Fluttertoast.showToast(
          msg: 'Auto-capture on',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Duration duration =  Duration(seconds: 5);
        Timer(duration, () async {
          initSensorListener();
          if (isShaking == false) {
//send the image

            await _initializeControllerFuture;

            // Start auto-focusing
            await _controller.setFocusMode(FocusMode.auto);

            // Wait for auto-focus to complete
            await Future.delayed(const Duration(seconds: 1));

            if (_isAutoOn) {
              // Capture the image

              XFile imageFile = await _controller.takePicture();
              final pngBytes = await imageFile.readAsBytes();
              final file = await _savePicture(pngBytes);
              a = file.path;
              File imgFile = File(a);
              //bool isBlurry = await checkImageBlur(imgFile);
             // if (!isBlurry) {
                NativeShutterSound.play();
              String userId = getCurrentUserId();
              await uploadImage(userId);
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const captureImage(),
                  ),
                );
                dispose();
              /*} else {
                _toggleAuto();
              }*/
            }
          } else {
            _toggleAuto();
          }
        });
      } else {
        !_isAutoOn;
        Fluttertoast.showToast(
          msg: 'Auto-capture off',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void _addDot(Rect area) {
    final random = Random();
    final x = area.left + random.nextDouble() * area.width;
    final y = area.top + random.nextDouble() * area.height;
    setState(() {
      _dots.add(Offset(x, y));
      if (_dots.length > 15) {
        _dots.removeAt(0);
      }
    });
  }

  void fun() async {
    Fluttertoast.showToast(
      msg: 'Auto-capture on',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
    Duration duration = const Duration(seconds: 8);
    Timer(duration, () async {
      await _initializeControllerFuture;

      // Start auto-focusing
      await _controller.setFocusMode(FocusMode.auto);

      // Wait for auto-focus to complete
      await Future.delayed(const Duration(seconds: 1));

      bool isShaking = false;

      accelerometerEvents.listen((AccelerometerEvent event) {
        double deltaX = event.x;
        double deltaY = event.y;
        double deltaZ = event.z;
        double magnitude = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ;
        if (magnitude > 101.0 && magnitude < 97.0) {
          isShaking = true;
        } else {
          isShaking = false;
          //print("Magnitude:");
          //print(magnitude);
        }
      });

      // Wait for shaking to stop or for the timer to expire
      bool hasStoppedShaking = false;
      while (!hasStoppedShaking) {
        if (!isShaking) {
          hasStoppedShaking = true;
          break;
        }
        //await Future.delayed(Duration(milliseconds: 50));
      }

      if (hasStoppedShaking) {
        if (_isAutoOn) {
          // Capture the image
          XFile imageFile = await _controller.takePicture();
          final pngBytes = await imageFile.readAsBytes();
          final file = await _savePicture(pngBytes);
          a = file.path;
          File imgFile = File(a);
          //bool isBlurry = await checkImageBlur(imgFile);
          //if (!isBlurry) {
            NativeShutterSound.play();
          String userId = getCurrentUserId();
          await uploadImage(userId);
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const captureImage(),
              ),
            );
            dispose();
         /* } else {
            fun();
          }*/
        }
     } else {
        _toggleAuto();
      }
    });
  }

  void runOnce(Function function) {
    if (!_hasRun) {
      function();
      _hasRun = true;
    }
  }

  bool _hasRun = false;

  @override
  void dispose() async {
    // Dispose of the camera controller when the widget is disposed
    await Future.delayed(const Duration(seconds: 1));
    _controller.setFlashMode(FlashMode.off);
    _controller.dispose();
    _animationController.dispose();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> uploadImage(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.white,
            secondRingColor: Colors.green,
            thirdRingColor: Colors.yellow,
            size: 100,
          ),
        );
      },
    );
    var url = link+'api/image?user_id=$userId'; // Replace with your website's URL

    // Get the image file from local storage
    String imagePath = a;
    File imageFile = File(imagePath);

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Attach the file to the request
    var imageStream = http.ByteStream(imageFile.openRead());
    var imageLength = await imageFile.length();
    var imageUpload = http.MultipartFile(
      'file',
      imageStream,
      imageLength,
      filename: 'image.jpeg',
    );
    request.files.add(imageUpload);

    // Add the user ID to the request
    //request.fields['user_id'] = userId;

    // Send the request
    var response = await request.send();

    // Check the response status
    if (response.statusCode == 200) {
      // Image uploaded successfully
      String result = await response.stream.bytesToString();
      List<String> split_res = result.split(":");
      List<String> ped_list = split_res[split_res.length-1].split("}");
      ped = ped_list.first.toString();
      med = split_res[split_res.length-2].split(",").first.toString();
      print(med+ "   " +ped);
      print('Image uploaded');
    } else {
      // Error uploading image
      print('Error uploading image: ${response.reasonPhrase}');
    }
    Navigator.of(context, rootNavigator: true).pop();
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


  Future<bool> checkImageBlur(File imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5000'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      return result.toLowerCase() == 'true';
    } else {
      throw Exception('Failed to upload image: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    runOnce(fun);
    Size screenSize = Utils().getScreenSize();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 120, 162, 204),
          automaticallyImplyLeading: true,
          leading: IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _isAutoOn = false;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const home();
                    },
                  ),
                );
                dispose();
              }),
          actions: [
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.yellow.shade500,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Colors.tealAccent[400]),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black12,
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!_isAutoOn) {
                return Stack(
                  children: [
                    CameraPreview(_controller),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 3.5 - 100,
                      left: MediaQuery.of(context).size.width / 3.5 - 100,
                      child: Image.asset(
                        'assets/search.png',
                        fit: BoxFit.cover,
                        width: screenSize.width * 1,
                        height: screenSize.width * 1,
                      ),
                    ),
                  ],
                );
              } else {
                return Stack(
                  children: [
                    CameraPreview(_controller),
                    CustomPaint(
                      painter:
                          _BlisteringDotsPainter(_animationController, _dots),
                      size: MediaQuery.of(context).size,
                    ),
                  ],
                );
              }
            } else {
              // Otherwise, display a loading spinner
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: SizedBox(
          height: screenSize.height * 0.18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.black12,
                onPressed: _toggleAuto,
                elevation: 0.0,
                child: Icon(
                  _isAutoOn
                      ? Icons.close_rounded
                      : Icons.camera_enhance_rounded,
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.black12,
                onPressed: () async {
                  try {
                    // Ensure that the camera is initialized before taking a picture

                    _isAutoOn = false;
                    await _initializeControllerFuture;

                    // Start auto-focusing
                    await _controller.setFocusMode(FocusMode.auto);

                    // Wait for auto-focus to complete
                    await Future.delayed(const Duration(seconds: 1));

                    // Capture the image

                    XFile imageFile = await _controller.takePicture();

                    NativeShutterSound.play();

                    final pngBytes = await imageFile.readAsBytes();
                    final file = await _savePicture(pngBytes);
                    a = file.path;
                    String userId = getCurrentUserId();
                    await uploadImage(userId);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const captureImage(),
                      ),
                    );
                    dispose();

                    // Do something with the captured image
                    // ...
                  } catch (e) {
                    // Handle errors
                  }
                },
                child: const Icon(Icons.search_rounded),
              ),
              FloatingActionButton(
                backgroundColor: Colors.black12,
                onPressed: () async {
                  _isAutoOn = false;
                  FlashMode.off;
                  await _controller.setFlashMode(FlashMode.off);
                  final file = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (file != null) {
                    // Do something with the picked image
                    a = file.path;

                    String userId = getCurrentUserId();
                    await uploadImage(userId);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const captureImage(),
                      ),
                    );
                  }
                  // TODO: Add gallery access logic here
                },
                child: const Icon(Icons.photo_library_rounded),
              ),
              //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _BlisteringDotsPainter extends CustomPainter {
  final Animation<double> _animation;
  final List<Offset> _dots;
  final Paint _paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  _BlisteringDotsPainter(this._animation, this._dots)
      : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 85;
    for (var dot in _dots) {
      canvas.drawCircle(
        dot,
        radius * _animation.value,
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BlisteringDotsPainter oldDelegate) {
    return true;
  }
}

// ignore: camel_case_types
class captureImage extends StatefulWidget {
  const captureImage({Key? key}) : super(key: key);

  @override
  State<captureImage> createState() => _captureImageState();
}

// ignore: camel_case_types
class _captureImageState extends State<captureImage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // rest of the code
  FlutterTts flutterTts = FlutterTts();
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String langCode = "en-US";
  String medicineText = "Medicine name: " + med + "\n" + " Dosage time: " + ped;
  late AnimationController _animationController;
  Timer? _timer;
  final List<Offset> _dots = [];

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void initState() {
    init();
    super.initState();
    // Initialize the camera controller future

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat();

    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final area = Rect.fromLTWH(
          0,
          MediaQuery
              .of(context)
              .size
              .height / 12,
          MediaQuery
              .of(context)
              .size
              .width,
          MediaQuery
              .of(context)
              .size
              .height / 1.6);
      _addDot(area);
    });
  }

  void _addDot(Rect area) {
    final random = Random();
    final x = area.left + random.nextDouble() * area.width;
    final y = area.top + random.nextDouble() * area.height;
    setState(() {
      _dots.add(Offset(x, y));
      if (_dots.length > 15) {
        _dots.removeAt(0);
      }
    });
  }

  void init() async {
    preferences = await SharedPreferences.getInstance();
    loadPreferences();
    languages = List<String>.from(await flutterTts.getLanguages);
    setState(() {});
  }
  void loadPreferences() {
    volume = preferences!.getDouble('volume') ?? 1.0;
    pitch = preferences!.getDouble('pitch') ?? 1.0;
    speechRate = preferences!.getDouble('speechRate') ?? 0.5;
    langCode = preferences!.getString('langCode') ?? 'en-US';
  }
  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    _animationController.dispose();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black12,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: screenSize.height * 0.85,
                    width: screenSize.width * 1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image(
                      image: FileImage(File(a), scale: 1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: 0.235,
                minChildSize: 0.115,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    height: 400.0,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(medicineText),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                              onPressed: () {
                                // Handle button press here
                                Clipboard.setData(ClipboardData(text: medicineText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Text copied to clipboard')),
                                );
                              },
                              child: Row(
                        children: [
                          Text('Copy Text '),
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.yellow.shade500,
                                ),],),
                              ),
                        ElevatedButton(
                        onPressed: () {
                        // Handle button press here
                          _speak();
                        },
                        child: Row(
                        children: [
                        Text('Hear '),
                        Icon(
                        Icons.volume_up_rounded,
                        color: Colors.yellow.shade500,
                        ),],),
                        ),
                        ],
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          height: screenSize.height * 0.075,
          color: Colors.black12,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraView(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const home(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void initSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(langCode);
  }

  void _speak() async {
    initSetting();
    await flutterTts.speak(medicineText);
  }
}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({Key? key}) : super(key: key);

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {
  FlutterTts flutterTts = FlutterTts();
  final String currentPage = 'Text to speech settings';
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String langCode = "en-US";


  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    preferences = await SharedPreferences.getInstance();
    loadPreferences();
    languages = List<String>.from(await flutterTts.getLanguages);
    setState(() {});
  }

  void loadPreferences() {
    volume = preferences!.getDouble('volume') ?? 1.0;
    pitch = preferences!.getDouble('pitch') ?? 1.0;
    speechRate = preferences!.getDouble('speechRate') ?? 0.5;
    langCode = preferences!.getString('langCode') ?? 'en-US';
  }

  void savePreferences() {
    preferences!.setDouble('volume', volume);
    preferences!.setDouble('pitch', pitch);
    preferences!.setDouble('speechRate', speechRate);
    preferences!.setString('langCode', langCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 162, 204),
        centerTitle: true,
        title: const Text("Text To Speech"),
      ),
      body: SingleChildScrollView(
    child:Container(
        margin: const EdgeInsets.only(top: 20),
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        "Volume",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 1.0,
                      value: volume,
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                        });
                      },
                      activeColor: Color.fromARGB(255, 68, 243, 168),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        double.parse((volume).toStringAsFixed(2)).toString(),
                        style: const TextStyle(fontSize: 17),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        "Pitch",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Slider(
                      min: 0.5,
                      max: 2.0,
                      value: pitch,
                      onChanged: (value) {
                        setState(() {
                          pitch = value;
                        });
                      },
                      activeColor: Color.fromARGB(255, 68, 243, 168),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        double.parse((pitch).toStringAsFixed(2)).toString(),
                        style: const TextStyle(fontSize: 17),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        "Speech Rate",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 1.0,
                      value: speechRate,
                      onChanged: (value) {
                        setState(() {
                          speechRate = value;
                        });
                      },
                      activeColor: Color.fromARGB(255, 68, 243, 168),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        double.parse((speechRate).toStringAsFixed(2)).toString(),
                        style: const TextStyle(fontSize: 17),
                      ),
                    )
                  ],
                ),
              ),
              if (languages != null)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      const Text(
                        "Language :",
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      DropdownButton<String>(
                        focusColor: Colors.white,
                        value: langCode,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.black,
                        items: languages!
                            .map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                            value: value!,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            langCode = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 25,
              ),
              ElevatedButton(onPressed: (){    savePreferences();},style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 68, 243, 168), // Set the button color to yellow
              ), child: Text("   Save   "))
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    savePreferences();
    super.dispose();
  }
}

