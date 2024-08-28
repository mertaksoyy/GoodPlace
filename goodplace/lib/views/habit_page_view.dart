import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HabitPageView extends StatefulWidget {
  const HabitPageView({super.key});

  @override
  State<HabitPageView> createState() => _HabitPageViewState();
}

class _HabitPageViewState extends State<HabitPageView> {
  final _formKey = GlobalKey<FormState>(); // Form durumu için GlobalKey
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

  // Azure OpenAI API'sine title göndererek purpose oluşturma fonksiyonu
  Future<String> generatePurpose(String title) async {
    final url = Uri.parse(
        'https://patrons-openai.openai.azure.com/openai/deployments/GrowTogether/chat/completions?api-version=2024-02-15-preview');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'api-key': openAiApiKey,
      },
      body: jsonEncode({
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that generates short purposes for habits.'
          },
          {
            'role': 'user',
            'content':
                'Write a short purpose for the habit titled "$title". Purpose should be concise and under 25 characters.'
          }
        ],
        'max_tokens': 25,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final purpose = data['choices'][0]['message']['content'].trim();
      return purpose;
    } else {
      throw Exception('Failed to generate purpose');
    }
  }

  Future<void> _loadTotalHabit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalHabit = prefs.getInt('totalHabit') ?? 0; // Eğer yoksa 0 olarak al
    });
  }

  Future<void> _updateTotalHabit(int newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalHabit = newValue;
      prefs.setInt('totalHabit', totalHabit); // totalHabit'i sakla
    });
  }

  Future<void> storeData() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String title = titleController.text;
        String purpose = purposeController
            .text; // Kullanıcı ya da AI tarafından oluşturulmuş purpose

        // Yeni bir habit eklerken veritabanına yazma işlemi
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

        // Veritabanına başarılı bir şekilde yazıldıktan sonra totalHabit'i artır
        await _updateTotalHabit(totalHabit + 1);

        // Verileri kaydettikten sonra formu resetle ve dialog'u kapat
        resetForm();
        Navigator.pop(context);
      } catch (e) {
        print("Error saving data: $e");
      }
    }
  }

  Future<void> updateData(DocumentSnapshot document) async {
    if (_formKey.currentState?.validate() ?? false) {
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
            'streakCount': currentStreakCount,
            'lastUpdatedDate': today,
          });
        }

        // Streak count artırılsın veya artırılmasın title ve purpose'ı güncelle
        await habitsCollection.doc(document.id).update({
          'title': title,
          'purpose': purpose,
        });

        Navigator.pop(context); // Verileri güncelledikten sonra dialog'u kapat
      } catch (e) {
        print("Error updating data: $e");
      }
    }
  }

  Future<void> deleteHabit(DocumentSnapshot document) async {
    try {
      await habitsCollection.doc(document.id).delete();
      _updateTotalHabit(totalHabit - 1); // Habit silindiğinde azalt
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  void resetForm() {
    setState(() {
      titleController.clear();
      purposeController.clear();
      streakCount = 0;
      _controller.text = streakCount.toString();
    });
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
    /*
    if (documentId != null) {
      await habitsCollection.doc(documentId).update({
        'imagePath': image.path,
      });
    }
    */
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

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No habits found"));
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
                        onPressed: titleController.clear,
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
                    onPressed: () {
                      if (titleController.text.isEmpty) {
                        setState(() {});
                        titleError = true;
                      } else if (purposeController.text.isEmpty) {
                        setState(() {
                          purposeError = true;
                        });
                      } else {
                        Navigator.of(context)
                            .popAndPushNamed(myHabitsViewRoute);
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
