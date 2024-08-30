import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';
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
  File? selectedImage;
  String imagePath = 'assets/images/buyuk.png';
  final String openAiApiKey = '9070bb36762b4ddc8552f51b98091334';

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Oturum açmış kullanıcı

  String imageUrl = '';
  late final imageIndex;
  bool titleError = false;
  bool purposeError = false;

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

  @override
  void initState() {
    _controller = TextEditingController(text: streakCount.toString());
    imageIndex = Random().nextInt(3) + 1;
    super.initState();
    getImageUrl('image${imageIndex.toString()}.jpg').then((url) {
      setState(() {
        imageUrl = url;
      });
    }); // Uygulama başladığında totalHabit'i yükle
  }

  Future<void> storeData() async {
    try {
      String title = titleController.text;
      String purpose = purposeController.text;
      await habitsCollection.add({
        'title': title,
        'purpose': purpose,
        'streakCount': 0,
        'lastUpdatedDate': null,
        'imagePath': selectedImage != null ? selectedImage!.path : imageUrl,
        'userId': currentUser?.uid, // Oturum açmış kullanıcının UID'sini ekle
      });
      Navigator.pop(context);
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xff556B2F),
        centerTitle: true,
        title: const Text(
          "Create a habit",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
              return const Center(child: Text("Error loading data"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
                // ignore: prefer_const_constructors
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
                            : (imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl) as ImageProvider
                                : const AssetImage(
                                    'assets/images/loading.webp')), // Geçerli bir placeholder resmi kullanın
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
                    child: const Center(
                        child: Text('Insert an image from gallery')),
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
                        await storeData();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            myHabitsViewRoute, (Route<dynamic> route) => false);
                      }
                    },
                    child: const Center(child: Text('Create Habit')),
                  ),
                ),
              ]),
            ));
          }),
    );
  }
}
