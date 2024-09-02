import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/services/ai_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateHabit extends StatefulWidget {
  const CreateHabit({super.key});

  @override
  State<CreateHabit> createState() => _CreateHabitState();
}

class _CreateHabitState extends State<CreateHabit> {
  TextEditingController titleController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  int streakCount = 0;
  int totalHabit = 0;
  late TextEditingController _controller;
  final String openAiApiKey =
      'YOUR_OPENAI_API_KEY'; // Bu kısmı doğru API anahtarıyla değiştirin

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  final User? currentUser = FirebaseAuth.instance.currentUser;

  String imageUrl = '';
  late final imageIndex;
  bool titleError = false;
  bool purposeError = false;

  PlatformFile? pickedFile;

  @override
  void initState() {
    _controller = TextEditingController(text: streakCount.toString());
    imageIndex = Random().nextInt(3) + 1;
    super.initState();
    getImageUrl('image${imageIndex.toString()}.jpg').then((url) {
      setState(() {
        imageUrl = url;
      });
    });
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      final Reference ref = FirebaseStorage.instance.ref().child(imagePath);
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error occurred while fetching image URL: $e");
      return '';
    }
  }

  Future<void> storeData() async {
    try {
      String title = titleController.text;
      String purpose = purposeController.text;
      DateTime currentDate = DateTime.now();

      await habitsCollection.add({
        'title': title,
        'purpose': purpose,
        'streakCount': 0,
        'lastUpdatedDate': currentDate,
        'imagePath': imageUrl,
        'startDate': currentDate,
        'highStreakCount': 0,
        'isStreakIncrement': false,
        'userId': currentUser?.uid,
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future uploadFile() async {
    if (pickedFile != null) {
      final path = "${currentUser?.uid}/${pickedFile!.name}";
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      imageUrl = await ref.getDownloadURL();
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xff8E97FD),
        centerTitle: true,
        title: const Text(
          "Create a habit",
          style: TextStyle(
              fontSize: 25,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: Color(0xffFFECCC)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: habitsCollection
              .where('userId', isEqualTo: currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              backgroundColor: Color(0xff8E97FD),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200.00,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: pickedFile != null
                                ? FileImage(File(pickedFile!.path!))
                                : (imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl) as ImageProvider
                                    : const AssetImage(
                                        'assets/images/loading.webp')),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        maxLength: 25,
                        controller: titleController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black),
                          counterStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white,
                          filled: true,
                          suffixIcon: IconButton(
                            onPressed: () {
                              titleController.clear();
                              purposeController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                          labelText: 'Enter a Habit Title',
                          hintText: 'Enter a habit title',
                          errorText: titleError && titleController.text.isEmpty
                              ? "Title Can't Be Empty"
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onChanged: (value) {
                          if (titleError && value.isNotEmpty) {
                            setState(() {
                              titleError = false;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: purposeController,
                        maxLines: null,
                        maxLength: 200,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black),
                          counterStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (titleController.text.isNotEmpty) {
                                    try {
                                      String purpose = await generatePurpose(
                                          titleController.text);
                                      setState(() {
                                        purposeController.text = purpose;
                                      });
                                    } catch (e) {
                                      print("Error generating AI purpose: $e");
                                    }
                                  } else {
                                    setState(() {
                                      titleError = true;
                                    });
                                  }
                                },
                                icon: SvgPicture.asset(
                                    width: 30,
                                    height: 30,
                                    'assets/icon/magic.svg'),
                              ),
                              SizedBox(height: 15),
                              IconButton(
                                onPressed: purposeController.clear,
                                icon: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                          hintText: 'Enter a habit purpose',
                          labelText: 'Enter a Habit Purpose',
                          errorText:
                              purposeError && purposeController.text.isEmpty
                                  ? "Purpose Can't Be Empty"
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onChanged: (value) {
                          if (purposeError && value.isNotEmpty) {
                            setState(() {
                              purposeError = false;
                            });
                          }
                        },
                      ),
                    ),
                    /*   
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        
                        onPressed: () async {
                          if (titleController.text.isNotEmpty) {
                            try {
                              String purpose =
                                  await generatePurpose(titleController.text);
                              setState(() {
                                purposeController.text = purpose;
                              });
                            } catch (e) {
                              print("Error generating AI purpose: $e");
                            }
                          } else {
                            setState(() {
                              titleError = true;
                            });
                          }
                        },
                        
                        child:
                            const Center(child: Text('Create purpose with AI')),
                      ),
                    ),
                    */
                    SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          await selectFile();
                        },
                        child: const Center(
                          child: Text(
                            'Insert an image from gallery',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            setState(() {});
                            titleError = true;
                          } else if (purposeController.text.isEmpty) {
                            setState(() {
                              purposeError = true;
                            });
                          } else {
                            await uploadFile();
                            await storeData();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                myHabitsViewRoute,
                                (Route<dynamic> route) => false);
                          }
                        },
                        child: Center(
                            child: Text(
                          'Create Habit',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
