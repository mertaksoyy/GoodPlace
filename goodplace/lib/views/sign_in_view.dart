import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignInView> {
  final String screenMessage = 'Welcome Back!';
  final String gButtonMessage = 'CONTINUE WITH GOOGLE';
  final String textMessage1 = 'OR LOG IN WITH EMAIL';

  final String lastMessage1 = "DON'T HAVE AN ACCOUNT?";
  final String lastMessage2 = " SIGN UP";

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.clear();
    passwordController.clear();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    const devHeight = 896;

    final welcomeHeight = height * 28.47 / devHeight;
    final googleButtonHeight = height * 116 / devHeight;
    final loginTextHeight = height * 40 / devHeight;
    final emailTextFieldHeight = height * 39 / devHeight;
    final passwordTextFieldHeight = height * 20 / devHeight;
    final loginButtonHeight = height * 30 / devHeight;
    final forgotPasswordHeight = height * 20 / devHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(welcomePageRoute);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: welcomeHeight),
                  child: Text(
                    style: GoogleFonts.rubik(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    screenMessage,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, googleButtonHeight, 20, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.76),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final GoogleSignInAccount? userWithGoogle =
                            await GoogleSignIn().signIn();
                        final GoogleSignInAuthentication userAuth =
                            await userWithGoogle!.authentication;
                        final credentials = GoogleAuthProvider.credential(
                          accessToken: userAuth.accessToken,
                          idToken: userAuth.idToken,
                        );
                        final UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithCredential(credentials);
                        print(userCredential.user?.email);
                      } on FirebaseAuthException catch (e) {
                        print(e.code);
                      }

                      Navigator.of(context).pushNamed(mainPageRoute);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          gButtonMessage,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: loginTextHeight),
                  child: Text(
                    textMessage1,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, emailTextFieldHeight, 20, 0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Email address',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(20, passwordTextFieldHeight, 20, 0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: 'Password',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, loginButtonHeight, 20, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.76),
                      ),
                    ),
                    onPressed: () async {
                      final email = emailController.text;
                      final password = passwordController.text;
                      try {
                        final userCredentials = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                      } on FirebaseAuthException catch (e) {
                        print(e.code);
                      }

                      Navigator.of(context).pushNamed(mainPageRoute);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'LOG IN',
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: forgotPasswordHeight),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.rubik(
                        fontSize: 14, fontStyle: FontStyle.normal),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lastMessage1,
                        style: GoogleFonts.rubik(
                            fontSize: 14, fontStyle: FontStyle.normal),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(signUpViewRoute);
                          },
                          child: Text('SIGN UP')),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
