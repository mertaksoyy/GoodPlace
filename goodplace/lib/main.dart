import 'package:flutter/material.dart';
import 'package:goodplace/view/sign_up.dart';
import 'package:goodplace/view/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: WelcomePage());
  }
}
