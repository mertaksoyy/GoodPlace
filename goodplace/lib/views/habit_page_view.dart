import 'package:flutter/material.dart';

class HabitPageView extends StatefulWidget {
  const HabitPageView({super.key});

  @override
  State<HabitPageView> createState() => _HabitPageViewState();
}

class _HabitPageViewState extends State<HabitPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Challenges",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Text("testdata"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff607D8B),
          onPressed: () {
            print("testdeneme");
          },
          child: Icon(Icons.add, color: Color(0xffFFFFFF))),
    );
  }
}
