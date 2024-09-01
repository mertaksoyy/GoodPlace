import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/firebase_options.dart';
import 'package:goodplace/service/notification_service.dart';
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
  NotificationService().setupFirebaseMessaging();
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
        home: const SplashScreen(),
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
    saveTokenToDatabase();
    requestNotificationPermissions();
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

Future<void> saveTokenToDatabase() async {
  // Firebase Messaging instance al
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FCM token'ı al
  String? token = await messaging.getToken();

  // Kullanıcı kimliği al (Kullanıcı giriş yaptıktan sonra mevcut olmalıdır)
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && token != null) {
    String userId = user.uid;

    // Firestore'da kullanıcı belgesini güncelle veya oluştur
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }
}

void requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _goHome();
    super.initState();
  }

  _goHome() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff94a9fe),
      body: Center(
        child: Image.asset('assets/images/splash1.png'),
      ),
    );
  }
}
