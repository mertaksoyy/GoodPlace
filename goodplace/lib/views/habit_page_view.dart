import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitPageView extends StatefulWidget {
  const HabitPageView({super.key});

  @override
  State<HabitPageView> createState() => _HabitPageViewState();
}

class _HabitPageViewState extends State<HabitPageView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  int streakCount = 0;
  late TextEditingController _controller;

  File? selectedImage; // Seçilen resmi saklamak için

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Oturum açmış kullanıcı

  @override
  void initState() {
    _controller = TextEditingController(text: streakCount.toString());
    super.initState();
  }

  Future<void> storeData() async {
    try {
      String title = titleController.text;
      String purpose = purposeController.text;

      // İlk kez oluştururken streak count artırılmıyor
      await habitsCollection.add({
        'title': title,
        'purpose': purpose,
        'streakCount': streakCount,
        'lastUpdatedDate': null,
        'imagePath': selectedImage != null
            ? selectedImage!.path
            : null, // Store image path
        'userId': currentUser?.uid, // Oturum açmış kullanıcının UID'sini ekle
      });

      Navigator.pop(context); // Verileri kaydettikten sonra dialog'u kapat
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future<void> updateData(DocumentSnapshot document) async {
    try {
      String title = titleController.text;
      String purpose = purposeController.text;
      int currentStreakCount = document['streakCount'];
      DateTime? lastUpdatedDate = (document['lastUpdatedDate'] != null)
          ? (document['lastUpdatedDate'] as Timestamp).toDate()
          : null;
      DateTime today = DateTime.now();

      // Eğer streakCount bugün zaten artırılmışsa artırma
      if (lastUpdatedDate == null ||
          lastUpdatedDate.day != today.day ||
          lastUpdatedDate.month != today.month ||
          lastUpdatedDate.year != today.year) {
        currentStreakCount += 1;

        await habitsCollection.doc(document.id).update({
          'title': title,
          'purpose': purpose,
          'streakCount': currentStreakCount,
          'lastUpdatedDate': today,
        });

        Navigator.pop(context); // Verileri güncelledikten sonra dialog'u kapat
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Streak can only be increased once per day."),
        ));
      }
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  void resetForm() {
    setState(() {
      titleController.clear();
      purposeController.clear();
      streakCount = 0;
      _controller.text = streakCount.toString();
      selectedImage = null; // Form resetlendiğinde seçilen resmi de sıfırla
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Habits",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: habitsCollection
            .where('userId',
                isEqualTo: currentUser
                    ?.uid) // Yalnızca oturum açmış kullanıcının alışkanlıklarını filtrele
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No habits found"));
          }

          final habits = snapshot.data!.docs;

          return ListView(
            padding: EdgeInsets.all(10),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: habits.map((habit) {
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        titleController.text = habit['title'];
                        purposeController.text = habit['purpose'];
                        streakCount = habit['streakCount'];
                        _controller.text = streakCount.toString();

                        return myHabitEditBox(
                          context: context,
                          document: habit,
                          onPressed: () => updateData(habit),
                        );
                      },
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit['title'],
                                    style: GoogleFonts.rubik(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Purpose: ${habit['purpose']}",
                                    style: GoogleFonts.rubik(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Streak Count: ${habit['streakCount']}",
                                    style: GoogleFonts.rubik(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Today: $todayDate",
                                    style: GoogleFonts.rubik(
                                        fontSize: 16, color: Colors.blueGrey),
                                  ),
                                  habit['imagePath'] != null
                                      ? Image.file(
                                          File(habit['imagePath']),
                                          height: 100,
                                          width: 100,
                                        )
                                      : Text("No image selected"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Color(0xff4D57C8)),
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Habit"),
                                    content: Text(
                                        "Are you sure you want to delete this habit?"),
                                    actions: [
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text("Delete"),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete == true) {
                                deleteHabit(habit);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff607D8B),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return myHabitBox(context: context, onPressed: storeData);
              });
        },
        child: Icon(Icons.add, color: Color(0xffFFFFFF)),
      ),
    );
  }

  Dialog myHabitBox({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Create Your Habit",
                      style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetForm();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                commonTextField("Title", titleController),
                commonTextField("Purpose", purposeController),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    controller: _controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Streak Count",
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.blue, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                    ),
                  ),
                ),
                selectedImage != null
                    ? Image.file(
                        selectedImage!,
                        height: 100,
                        width: 100,
                      )
                    : Text("The photo you selected will be displayed!"),
                ElevatedButton(
                  child: Text("Insert an image from gallery"),
                  onPressed: () {
                    _pickImageFromGallery(null);
                  },
                ),
                ElevatedButton(
                  child: Text("Create Habit"),
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Dialog myHabitEditBox({
    required BuildContext context,
    required DocumentSnapshot document,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Your Habit",
                      style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetForm();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                commonTextField("Title", titleController),
                commonTextField("Purpose", purposeController),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextFormField(
                    controller: _controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Streak Count",
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.blue, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide:
                              BorderSide(color: Colors.black, width: 2)),
                    ),
                  ),
                ),
                document['imagePath'] != null
                    ? Image.file(
                        File(document['imagePath']),
                        height: 100,
                        width: 100,
                      )
                    : Text("No image selected"),
                ElevatedButton(
                  child: Text("Done"),
                  onPressed: onPressed,
                ),
                ElevatedButton(
                  child: Text("Insert an image from gallery"),
                  onPressed: () {
                    _pickImageFromGallery(document.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding commonTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
      ),
    );
  }

  Future<void> deleteHabit(DocumentSnapshot document) async {
    try {
      await habitsCollection.doc(document.id).delete();
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  Future<void> _pickImageFromGallery(String? documentId) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      selectedImage =
          File(image.path); // Seçilen resim setState ile yenileniyor
    });

    if (documentId != null) {
      await habitsCollection.doc(documentId).update({
        'imagePath': image.path,
      });
    }
  }
}
