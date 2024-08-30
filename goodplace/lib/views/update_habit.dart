import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/habit.dart';
import 'package:goodplace/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';

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

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  Future<void> _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      selectedImage =
          File(image.path); // Seçilen resim setState ile yenileniyor
    });
  }

  @override
  Widget build(BuildContext context) {
    habit = ModalRoute.of(context)!.settings.arguments as Habit;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update the habit'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200.00,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: selectedImage != null
                        ? FileImage(selectedImage!)
                        : NetworkImage(habit.imagePath)
                            as ImageProvider, // Geçerli bir placeholder resmi kullanın
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
                  suffixIcon: IconButton(
                    onPressed: purposeController.clear,
                    icon: const Icon(Icons.clear),
                  ),
                  hintText: 'Enter a habit purpose',
                  labelText: 'Enter a Habit Purpose',
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
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    try {
                      // Yapay zeka ile purpose üretme kısmı
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
                child: const Center(child: Text('Create purpose with AI')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _pickImageFromGallery();
                },
                child:
                    const Center(child: Text('Insert an image from gallery')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    setState(() {});
                    titleError = true;
                  } else if (purposeController.text.isEmpty) {
                    setState(() {
                      purposeError = true;
                    });
                  } else {
                    habitsCollection.doc(habit.id).update({
                      'title': titleController.text,
                      'purpose': purposeController.text,
                    });
                    Navigator.of(context)
                        .pushReplacementNamed(myHabitsViewRoute);
                  }
                },
                child: const Center(child: Text('Update Habit')),
              ),
            ),
          ]),
        ));
  }
}
