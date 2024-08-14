import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late final tfMailController;
  late final tfPassController;
  bool showOnboarding = true;

  @override
  void initState() {
    tfMailController = TextEditingController();
    tfPassController = TextEditingController();
    loadPrefs;
    super.initState();
  }

  Future<void> get loadPrefs async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    showOnboarding = prefs.getBool('res') ?? true;
    print(showOnboarding);
  }
  
  @override
  void dispose() {
    tfMailController.clear();
    tfPassController.clear();
    tfMailController.dispose();
    tfPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Stack(
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
                        controller: tfMailController,
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
                    Positioned(
                      top: 120.0, // signup.png'nin içinde konumlandırmak için
                      left: 95.0, // signup.png'nin içinde konumlandırmak için
                      child: Text(
                        "Welcome Back!",
                        style: GoogleFonts.rubik(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
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
                            onPressed: () {
                              signInWithGoogle();
                              showOnboarding
                                  ? Navigator.of(context)
                                      .pushNamed(onBoardViewRoute)
                                  : Navigator.of(context)
                                      .pushNamed(mainPageRoute);
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
                    controller: tfMailController,
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
                    obscureText: true,
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
                      final email = tfMailController.text;
                      final password = tfPassController.text;
                      try {
                        final userCredentials = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        Navigator.of(context).pushNamed(mainPageRoute);
                      } on FirebaseAuthException catch (e) {
                        print(e.code);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8E97FD),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
          ),
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    print('Google user is null');
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
