import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String openAiApiKey = '9070bb36762b4ddc8552f51b98091334';

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  final User? currentUser =
      FirebaseAuth.instance.currentUser; // Oturum açmış kullanıcı

  @override
  void initState() {
    _controller = TextEditingController(text: streakCount.toString());
    super.initState();
    _loadTotalHabit(); // Uygulama başladığında totalHabit'i yükle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Bildirimi göster veya işle
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });
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
      selectedImage = null;
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
        backgroundColor: Color(0xff556B2F),
        centerTitle: true,
        title: const Text(
          "My Habits",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
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
                            color: Color(0xffE6E6FA),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff8B4513)),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Purpose: ${habit['purpose']}",
                                    style: GoogleFonts.rubik(
                                        fontSize: 13, color: Color(0xff8B4513)),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.whatshot,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        habit['streakCount'].toString(),
                                        style: GoogleFonts.rubik(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Day: $todayDate",
                                    style: GoogleFonts.rubik(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 240, 70, 40)),
                                  ),
                                  habit['imagePath'] != null
                                      ? Image.file(
                                          File(habit['imagePath']),
                                          height: 100,
                                          width: 100,
                                        )
                                      : Text(""),
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
        backgroundColor: Color(0xff556B2F),
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
        child: Form(
          key: _formKey, // Form widget'ı içine GlobalKey ekleyin
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
                          _updateTotalHabit(totalHabit);
                          resetForm();
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  commonTextFieldWithCounter("Title", titleController, 25),
                  commonTextFieldWithCounter("Purpose", purposeController, 25),
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
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: Text("Create With AI"),
                        onPressed: () async {
                          if (titleController.text.isNotEmpty) {
                            try {
                              // Yapay zeka ile purpose üretme kısmı
                              String purpose =
                                  await generatePurpose(titleController.text);

                              // Purpose'ı TextController'a yaz
                              setState(() {
                                purposeController.text = purpose;
                              });
                            } catch (e) {
                              print("Error generating AI purpose: $e");
                            }
                          } else {
                            print("Title field cannot be empty");
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text("Create Habit"),
                        onPressed: onPressed,
                      ),
                    ],
                  ),
                ],
              ),
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
        child: Form(
          key: _formKey, // Form widget'ı içine GlobalKey ekleyin
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
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  commonTextFieldWithCounter("Title", titleController, 20),
                  commonTextFieldWithCounter("Purpose", purposeController, 20),
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
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2)),
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
      ),
    );
  }

  Padding commonTextFieldWithCounter(
      String label, TextEditingController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, TextEditingValue value, __) {
          return TextFormField(
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
            decoration: InputDecoration(
              labelText: label,
              suffixText: '${value.text.length}/$maxLength',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.black, width: 2)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label cannot be empty'; // Hata mesajını göster
              }
              return null;
            },
          );
        },
      ),
    );
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
