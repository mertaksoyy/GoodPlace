import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/firebase_options.dart';
import 'package:goodplace/views/habit_page_view.dart';
import 'package:goodplace/views/main_screen_view.dart';
import 'package:goodplace/views/onboarding_view.dart';
import 'package:goodplace/views/sign_in_view.dart';
import 'package:goodplace/views/sign_up.dart';
import 'package:goodplace/views/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        signInViewRoute: (context) => const SignInView(),
        signUpViewRoute: (context) => const SignUpPage(),
        welcomePageRoute: (context) => const WelcomePage(),
        mainPageRoute: (context) => MainScreenView(),
        onBoardViewRoute: (context) => const OnBoardPage(),
        habitPageViewRoute: (context) => const HabitPageView(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showOnboarding = true;
  void initState() {
    loadPrefs;
    super.initState();
  }

  Future<void> get loadPrefs async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    showOnboarding = prefs.getBool('res') ?? true;
    print(showOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              if (showOnboarding)
                return OnBoardPage();
              else
                return MainScreenView();
            } else {
              return WelcomePage();
            }
          default:
            return CircularProgressIndicator();
        }
      },
    );
  }
}
