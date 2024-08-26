import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/username_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainScreenView extends StatefulWidget {
  @override
  _MainScreenViewState createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  String? userName;
  int totalHabit = 0; // Toplam habit sayısını tutmak için değişken
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String quote =
      "There is an inspirational quote waiting for you just a click away!";
  String? email;
  int highStreak = 0;
  DateTime? lastUpdatedDate;

  @override
  void initState() {
    super.initState();
    _loadTotalHabit();
  }

  Future<void> _refreshData() async {
    await _fetchHabitData();
    await _loadTotalHabit();
  }

  // Firebase'den habit verilerini çeker
  Future<void> _fetchHabitData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('habits')
          .where('userId', isEqualTo: user.uid)
          .get();

      int maxStreak = 0;
      DateTime? lastDate;

      for (var doc in snapshot.docs) {
        final int streak = doc['streakCount'] ?? 0;
        final Timestamp? lastUpdate = doc['lastUpdatedDate'] as Timestamp?;
        final DateTime? date = lastUpdate?.toDate();

        if (streak > maxStreak) {
          maxStreak = streak;
        }

        if (date != null && (lastDate == null || date.isAfter(lastDate))) {
          lastDate = date;
        }
      }

      if (mounted) {
        setState(() {
          highStreak = maxStreak;
          lastUpdatedDate = lastDate;
        });
      }
    } catch (e) {
      print("Alışkanlık verilerini çekerken hata: $e");
    }
  }

  // SharedPreferences'tan toplam habit sayısını yükler
  Future<void> _loadTotalHabit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        totalHabit = prefs.getInt('totalHabit') ?? 0; // Varsayılan olarak 0 al
      });
    }
  }

  Future<void> fetchRandomQuote() async {
    final response =
        await http.get(Uri.parse("https://api.quotable.io/random"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          quote = data['content'];
        });
      }
    } else {
      throw Exception('Failed to load quote');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTotalHabit(); // Sayfa geri geldiğinde totalHabit'i yeniden yükle
    _fetchHabitData();
  }

  @override
  Widget build(BuildContext context) {
    userName = context.watch<UserNameProvider>().getUserName;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff8E97FD),
        title: Text(
          "Merhaba, $userName",
          style: GoogleFonts.rubik(
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
              fontSize: 20),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff8E97FD),
              ),
              child: Text(
                'Menu',
                style: GoogleFonts.rubik(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffFFECCC)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: ListTile(
                  title: const Text('Home Screen'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  trailing: Icon(Icons.home),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  title: const Text('Sign Out'),
                  onTap: () async {
                    final isLogOut = await showLogOutDialog(context);
                    if (isLogOut) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          welcomePageRoute, (_) => false);
                    }
                  },
                  trailing: Icon(Icons.logout),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: ListTile(
                  title: const Text('Delete the account'),
                  onTap: () {
                    deleteUserAccount();
                    Navigator.pushNamedAndRemoveUntil(
                        context, welcomePageRoute, (route) => false);
                  },
                  trailing: Icon(Icons.delete),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 185, 190, 243),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    weekendTextStyle: TextStyle(color: Colors.blue),
                    defaultTextStyle: TextStyle(color: Colors.blue),
                    todayTextStyle: TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    selectedDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Indicator(
                    color: Colors.blue,
                    text: 'All complete',
                  ),
                  SizedBox(width: 20),
                  Indicator(
                    color: Colors.white,
                    text: 'Some Complete',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: GestureDetector(
                onTap: fetchRandomQuote,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quote,
                    style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4D57C8)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, habitPageViewRoute);
                if (mounted) {
                  _refreshData(); // Sayfaya geri dönüldüğünde _loadTotalHabit(),_fetchHabitData() çağırılıyor
                }
              },
              child: Container(
                height: 220,
                child: Stack(
                  children: [
                    Positioned(
                        top: 25,
                        left: 20,
                        child: Material(
                          child: Container(
                            height: 180.0,
                            width: 350,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 103, 108, 167),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        )),
                    Positioned(
                      top: 10,
                      left: 30,
                      child: Card(
                        elevation: 10.0,
                        shadowColor:
                            Color.fromARGB(255, 253, 252, 253).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Color(0xff8E97FD),
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage("assets/images/buyuk.png")),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      left: 190,
                      child: Container(
                        width: 150,
                        height: 180,
                        child: Column(
                          children: [
                            Text(
                              "Click and create your new habits!",
                              style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffFFECCC)),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Text(
                              "Or track your habit!",
                              style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xffFFECCC)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  String title;
                  Widget content; // String yerine Widget kullanılıyor
                  switch (index) {
                    case 0:
                      title = "High Streak";
                      content = Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${highStreak} Gün",
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff4D57C8),
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.whatshot,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ],
                      );
                      break;
                    case 1:
                      title = "Total Habit's";
                      content = Text(
                        "${totalHabit.toString()}",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff4D57C8),
                        ),
                      );
                      break;
                    case 2:
                      title = "Last updated day";
                      content = Text(
                        lastUpdatedDate != null
                            ? DateFormat('dd MMM yyyy').format(lastUpdatedDate!)
                            : "No Update",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff4D57C8),
                        ),
                      );
                      break;
                    default:
                      title = "Veri Yok";
                      content = Text("");
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        width: 130, // Kartların genişliğini belirleyin
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(
                              0xffcadbfc), // Arka plan rengi burada ayarlandı
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4D57C8),
                              ),
                            ),
                            SizedBox(
                                height:
                                    5), // Başlık ve içerik arasındaki boşluk
                            content, // İçeriği burada görüntüle
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatefulWidget {
  final Color color;
  final String text;

  Indicator({required this.color, required this.text});

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(widget.text),
      ],
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Sign out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<void> deleteUserAccount() async {
  try {
    await FirebaseAuth.instance.currentUser!.delete();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  } on FirebaseAuthException catch (e) {
    print(e.code);

    if (e.code == "requires-recent-login") {
      await _reauthenticateAndDelete();
    } else {
      // Handle other Firebase exceptions
    }
  } catch (e) {
    print(e);
  }
}

Future<void> _reauthenticateAndDelete() async {
  try {
    final providerData = FirebaseAuth.instance.currentUser?.providerData.first;

    if (AppleAuthProvider().providerId == providerData!.providerId) {
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithProvider(AppleAuthProvider());
    } else if (GoogleAuthProvider().providerId == providerData.providerId) {
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithProvider(GoogleAuthProvider());
    }

    await FirebaseAuth.instance.currentUser?.delete();
  } catch (e) {
    // Handle exceptions
  }
}
