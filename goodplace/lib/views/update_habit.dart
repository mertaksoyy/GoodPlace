import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/habit.dart';
import 'package:goodplace/services/ai_service.dart';

class UpdateHabit extends StatefulWidget {
  const UpdateHabit({super.key});

  @override
  State<UpdateHabit> createState() => _UpdateHabitState();
}

class _UpdateHabitState extends State<UpdateHabit> {
  late TextEditingController titleController;
  late TextEditingController purposeController;
  late Habit habit;
  bool titleError = false;
  bool purposeError = false;
  File? selectedImage;
  String imageUrl = '';
  final User? currentUser = FirebaseAuth.instance.currentUser;

  PlatformFile? pickedFile;

  @override
  void initState() {
    titleController = TextEditingController();
    purposeController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the habit here, when the context is available
    habit = ModalRoute.of(context)!.settings.arguments as Habit;
    titleController.text = habit.title; // Set initial values from habit
    purposeController.text = habit.purpose;
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

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  @override
  Widget build(BuildContext context) {
    habit = ModalRoute.of(context)!.settings.arguments as Habit;
    return Scaffold(
        backgroundColor: Color(0xff8E97FD),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff8E97FD),
          title: const Text(
            'Update the habit',
            style: TextStyle(
                color: Color(0xffFFECCC), fontStyle: FontStyle.italic),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200.00,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: pickedFile != null
                        ? FileImage(File(pickedFile!.path!))
                        : NetworkImage(habit.imagePath) as ImageProvider,
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
                  fillColor: Colors.white,
                  filled: true,
                  labelStyle: TextStyle(color: Colors.black),
                  counterStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    onPressed: () {
                      titleController.clear();
                      purposeController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  labelText: 'Enter a Habit Title',
                  hintText: 'Enter a Habit Title',
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
                  counterStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Column(
                    children: [
                      IconButton(
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
                        icon: SvgPicture.asset(
                            width: 30, height: 30, 'assets/icon/magic.svg'),
                      ),
                      SizedBox(height: 15),
                      IconButton(
                        onPressed: purposeController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                  labelText: 'Enter a Habit Purpose',
                  hintText: 'Enter a Habit Purpose',
                  errorText: purposeError && purposeController.text.isEmpty
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await selectFile();
                },
                child: const Center(
                    child: Text(
                  'Insert an image from gallery',
                  style: TextStyle(color: Colors.black),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    setState(() {});
                    titleError = true;
                  } else if (purposeController.text.isEmpty) {
                    setState(() {
                      purposeError = true;
                    });
                  } else {
                    if (pickedFile != null) {
                      await uploadFile();
                      await habitsCollection.doc(habit.id).update({
                        'title': titleController.text,
                        'purpose': purposeController.text,
                        'imagePath': imageUrl,
                      });
                    } else {
                      await habitsCollection.doc(habit.id).update({
                        'title': titleController.text,
                        'purpose': purposeController.text,
                      });
                    }

                    Navigator.of(context)
                        .pushReplacementNamed(myHabitsViewRoute);
                  }
                },
                child: const Center(
                    child: Text(
                  'Update Habit',
                  style: TextStyle(color: Colors.black),
                )),
              ),
            ),
          ]),
        ));
  }
}
