import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/views/sign_in_view.dart';
import 'package:goodplace/view/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const SignInView(),
        signInViewRoute: (context) => const SignInView(),
        //signUpViewRoute: (context) => const SignUpView(),
      },
    );
  }
}
