import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/views/onboarding_view.dart';
import 'package:goodplace/views/sign_in_view.dart';
import 'package:goodplace/views/welcome_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  var tfMailontroller = TextEditingController();
  var tfPassController = TextEditingController();
<<<<<<< HEAD

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

=======
>>>>>>> 67c1c3c364c0b757cee6567a29badb562c6d1ac7
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              return Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/signup.png'),
                        ),
                        Positioned(
                          left: 17,
                          top: 50,
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, welcomePageRoute);
                              },
                              child: Image.asset(
                                  'assets/images/sign_up_back.png')),
                        ),
                        Positioned(
                          top:
                              120.0, // signup.png'nin içinde konumlandırmak için
                          left:
                              95.0, // signup.png'nin içinde konumlandırmak için
                          child: Text(
                            "Welcome Back!",
                            style: GoogleFonts.rubik(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
<<<<<<< HEAD
                        Positioned(
                            top: 155,
                            left: 0,
                            child: Image.asset(
                              'assets/images/signupdesign.png',
                              color: // Color(0xffFAF8F5)
                                  const Color.fromARGB(255, 240, 239, 237),
                            )),
                        Positioned(
                          top: 260,
                          left:
                              45, // Butonu biraz daha ortalamak için left değerini değiştirdim
                          child: Center(
                            child: SizedBox(
                              width: 300, // Genişliği artırdım
                              height: 60, // Yüksekliği artırdım
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final GoogleSignInAccount? userWithGoogle =
                                        await GoogleSignIn().signIn();
                                    final GoogleSignInAuthentication userAuth =
                                        await userWithGoogle!.authentication;
                                    final credentials =
                                        GoogleAuthProvider.credential(
                                      accessToken: userAuth.accessToken,
                                      idToken: userAuth.idToken,
                                    );
                                    final UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .signInWithCredential(credentials);
                                    print(userCredential.user?.email);
                                  } on FirebaseAuthException catch (e) {
                                    print(e.code);
                                  }
                                  Navigator.of(context)
                                      .pushNamed(onBoardViewRoute);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/googlesignin.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(
                                        width:
                                            15), // İkon ve metin arasındaki boşluk
                                    Text(
                                      "CONTINUE WITH GOOGLE",
                                      style: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff3F414E), // Metin rengi
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "OR LOG IN WITH EMAIL",
                      style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffA1A4B2)),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        controller: tfMailontroller,
                        textInputAction: TextInputAction.next,
                        //inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF2F3F7),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          labelText: "Email address",
                          labelStyle: GoogleFonts.rubik(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        controller: tfPassController,
                        textInputAction: TextInputAction.next,
                        //inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF2F3F7),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          labelText: "Password",
                          labelStyle: GoogleFonts.rubik(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 360,
                      height: 57,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff8E97FD),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40))),
                        child: Text(
                          "LOG IN",
                          style: GoogleFonts.rubik(
                              fontSize: 13.18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffF6F1FB)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
                      child: Text(
                        'Forgot Password?',
=======
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
                Padding(
                  padding: EdgeInsets.only(top: forgotPasswordHeight),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                    ),
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
>>>>>>> 67c1c3c364c0b757cee6567a29badb562c6d1ac7
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(60, 20, 50, 0),
                      child: Row(
                        children: [
                          Text("DON’T HAVE AN ACCOUNT?",
                              style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffA1A4B2))),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, signUpViewRoute);
                              },
                              child: Text(
                                " SIGN UP",
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff8E97FD)),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
<<<<<<< HEAD
              );
            },
          ),
        ),
      ),
    );
  }
}
=======
              ],
            );
          },
>>>>>>> 67c1c3c364c0b757cee6567a29badb562c6d1ac7
