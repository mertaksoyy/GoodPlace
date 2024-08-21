import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String quote =
      "There is an inspirational quote waiting for you just a click away!";
  String? email;
  Future<void> fetchRandomQuote() async {
    final response =
        await http.get(Uri.parse("https://api.quotable.io/random"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        quote = data['content'];
      });
    } else {
      throw Exception('Failed to load quote');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserName;
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email;
  }

  Future<void> get getUserName async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString(email!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff8E97FD),
        title: Text(
          "Merhaba, ${userName}",
          style: GoogleFonts.rubik(
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
              fontSize: 20),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: ListTile(
                  title: const Text('Home Screen'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Update the state of the app.
                    // ...
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
                    //final SharedPreferences prefs =
                    //    await SharedPreferences.getInstance();
                    //prefs.setBool("res", true);
                    Navigator.pushNamedAndRemoveUntil(
                        context, welcomePageRoute, (route) => false);
                    // Update the state of the app.
                    // ...
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
                    color: Colors.black12,
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
                    defaultTextStyle: TextStyle(color: Colors.blue),
                    todayTextStyle: TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    selectedDecoration: BoxDecoration(
                      color: Colors.red,
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
                  padding: EdgeInsets.all(
                      16), // İçerik ile sınırlar arasındaki boşluk
                  decoration: BoxDecoration(
                    color: Colors.white, // Arka plan rengi
                    borderRadius:
                        BorderRadius.circular(12), // Köşe yuvarlaklığı
                  ),
                  child: Text(
                    quote,
                    style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4D57C8)), // Yazı rengi
                    textAlign: TextAlign.center, // Yazıyı ortalar
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, habitPageViewRoute);
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
                            Color.fromARGB(255, 240, 238, 156).withOpacity(0.5),
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
                    )
                  ],
                ),
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
  } on FirebaseAuthException catch (e) {
    print(e.code);

    if (e.code == "requires-recent-login") {
      await _reauthenticateAndDelete();
    } else {
      // Handle other Firebase exceptions
    }
  } catch (e) {
    print(e);

    // Handle general exception
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
