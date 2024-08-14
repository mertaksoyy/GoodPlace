import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class MainScreenView extends StatefulWidget {
  @override
  _MainScreenViewState createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Future api() async {
    final response = await http.get(Uri.parse('https://api.quotable.io'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8E97FD),
      appBar: AppBar(
        leading: Icon(Icons.dehaze),
        backgroundColor: Color(0xff8E97FD),
        title: Text(
          "Habits",
          style: GoogleFonts.rubik(
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
              fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: api(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  Text("No data");
                }
                return Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    padding: EdgeInsets.all(
                        16), // İçerik ile sınırlar arasındaki boşluk
                    decoration: BoxDecoration(
                      color: Colors.white, // Arka plan rengi
                      borderRadius:
                          BorderRadius.circular(12), // Köşe yuvarlaklığı
                    ),
                    child: Text(
                      snapshot.data['quote'],
                      style: GoogleFonts.rubik(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4D57C8)), // Yazı rengi
                      textAlign: TextAlign.center, // Yazıyı ortalar
                    ),
                  ),
                );
              }),
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
        ],
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
