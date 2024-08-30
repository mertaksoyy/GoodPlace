import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/firebase_options.dart';
import 'package:goodplace/username_provider.dart';
import 'package:goodplace/views/create_habit.dart';
import 'package:goodplace/views/chatbot_page_view.dart';
import 'package:goodplace/views/main_screen_view.dart';
import 'package:goodplace/views/my_habits.dart';
import 'package:goodplace/views/onboarding_view.dart';
import 'package:goodplace/views/sign_in_view.dart';
import 'package:goodplace/views/sign_up.dart';
import 'package:goodplace/views/update_habit.dart';
import 'package:goodplace/views/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserNameProvider(), lazy: false),
      ],
      child: MaterialApp(
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
          createHabitViewRoute: (context) => CreateHabit(),
          myHabitsViewRoute: (context) => MyHabits(),
          updateHabitViewRoute: (context) => UpdateHabit(),
          chatBotViewRoute: (context) => ChatbotScreenView(),

        },
      ),
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

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  // Veriyi yükledikten sonra UserNameProvider'ı güncelleyin

  Future<void> loadPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showOnboarding = prefs.getBool('res') ?? true;
    });

    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userNameProvider =
          Provider.of<UserNameProvider>(context, listen: false);
      final name = FirebaseAuth.instance.currentUser!.displayName;
      userNameProvider.setUserName(name!); // Örnek veri
    });
    */
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
              if (showOnboarding) {
                return const OnBoardPage();
              } else {
                return MainScreenView();
              }
            } else {
              return const WelcomePage();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
