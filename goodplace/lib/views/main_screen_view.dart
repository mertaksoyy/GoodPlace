import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/habit.dart';
import 'package:goodplace/username_provider.dart';
import 'package:goodplace/utils.dart';
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

  late int length;
  List<String> habitTitles = [];
  late ConfettiController _myConfetti;

  DateTime _startDate = DateTime(2024, 8, 30);
  DateTime _endDate = DateTime(2024, 8, 31);

  @override
  void initState() {
    _myConfetti = ConfettiController();
    super.initState();
  }

  @override
  void dispose() {
    _myConfetti.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _fetchHabitData();
  }

/*
  Stream<List<Habit>> habitStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: user?.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }
  */
  Stream<List<Habit>> habitStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('highStreakCount', descending: true)
        .limit(5) // En yüksek 5 habit getir
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  // Firebase'den habit verilerini çeker
  Future<void> _fetchHabitData() async {
    final user = FirebaseAuth.instance.currentUser;
    length = 0;
    if (user == null) return;

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('habits')
          .where('userId', isEqualTo: user.uid)
          .get();

      length = snapshot.size;
      print('length');

      int maxStreak = 0;
      DateTime? lastDate;

      for (var doc in snapshot.docs) {
        final int streak = doc['streakCount'] ?? 0;
        final Timestamp? lastUpdate = doc['lastUpdatedDate'] as Timestamp?;
        final DateTime? date = lastUpdate?.toDate();
        final habitTitle = doc['title'] ?? '';
        habitTitles.add(habitTitle);

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
    super
        .didChangeDependencies(); // Sayfa geri geldiğinde totalHabit'i yeniden yükle
    _fetchHabitData();
  }

  final CollectionReference habitsCollection =
      FirebaseFirestore.instance.collection("habits");

  Future<void> _updateHabitInFirestore(Habit habit) async {
    try {
      await habitsCollection.doc(habit.id).update({
        'streakCount': habit.streakCount,
        'lastUpdatedDate': Timestamp.fromDate(habit.lastUpdatedDate),
        'highStreakCount': habit.highStreakCount,
        'isStreakIncrement':
            habit.isStreakIncrement, // Firestore'da yeni alanı güncelle
      });
    } catch (e) {
      print('Error updating habit: $e');
    }
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
            SizedBox(
              height: 128,
              child: DrawerHeader(
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
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: ListTile(
                  title: const Text('My Habits'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(myHabitsViewRoute);
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            StreamBuilder<List<Habit>>(
              stream: habitStream(), // Verileri dinleyen stream fonksiyonu
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No habits found.'));
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        color: Color(0xff8E97FD),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Show All Habits',
                                  style: TextStyle(
                                      color: Color(0xffFFECCC),
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(myHabitsViewRoute);
                                },
                                icon: Icon(Icons.arrow_forward),
                                color: Color(0xffFFECCC),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 4,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final habit = snapshot.data![index];
                              return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Card(
                                        color: Color(0xffE6E6FA),
                                        child: Stack(children: [
                                          Positioned.fill(
                                            child: Image.network(
                                              habit.imagePath,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              _selectedDay = habit.startDate;
                                              _focusedDay = habit.startDate;
                                              setState(() {});
                                            },
                                            leading: Icon(
                                              Icons.star,
                                              color: Color.fromARGB(
                                                  255, 245, 154, 17),
                                            ),
                                            title: Text(
                                                snapshot.data![index].title),
                                            trailing: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      !habit.isStreakIncrement,
                                                  child: ElevatedButton.icon(
                                                    icon: const Icon(
                                                        Icons.access_time),
                                                    onPressed: () async {
                                                      habit
                                                          .incrementStreakIfValid();
                                                      _myConfetti.play();
                                                      await Future.delayed(
                                                          const Duration(
                                                              seconds: 1));
                                                      _myConfetti.stop();
                                                      setState(() {});
                                                      await _updateHabitInFirestore(
                                                          habit);
                                                    },
                                                    label: Text('I did!'),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.whatshot,
                                                  color: Colors.orange,
                                                ),
                                                Text(
                                                  snapshot.data![index]
                                                      .highStreakCount
                                                      .toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    ConfettiWidget(
                                      confettiController: _myConfetti,
                                      blastDirection: -pi / 2,
                                    )
                                  ]);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, createHabitViewRoute);
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              "To start building a better routine today!",
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
                            "${highStreak} day",
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xffFFECCC),
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
                        "$length",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xffFFECCC),
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
                          color: Color(0xffFFECCC),
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
                              0xff8E97FD), // Arka plan rengi burada ayarlandı
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
                                color: Color(
                                    0xffFFECCC), // Title rengi güncellendi
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
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          backgroundColor: Color(0xff8E97FD),
          onPressed: () {
            Navigator.pushNamed(context, chatBotViewRoute);
          },
          child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                  'assets/images/robot.png') //SvgPicture.asset('assets/icon/icon.png'),
              ),
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
