import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/username_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var tfUserNameController = TextEditingController();
  var tfMailController = TextEditingController();
  var tfPassController = TextEditingController();
  String userName = "";
  bool isNameValid = false;
  bool isGmailValid = false;
  bool _obscureText = true;
  bool ischeckBox = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Kullanıcı adını kontrol eden dinleyici
    tfUserNameController.addListener(() {
      setState(() {
        isNameValid = tfUserNameController.text.isNotEmpty;
      });
    });

    // Mail adresini kontrol eden dinleyici
    tfMailController.addListener(() {
      setState(() {
        isGmailValid = tfMailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    tfUserNameController.dispose();
    tfMailController.dispose();
    tfPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Form(
            key: _formKey,
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
                          Navigator.pushNamed(context, signInViewRoute);
                        },
                        child: Image.asset('assets/images/sign_up_back.png'),
                      ),
                    ),
                    Positioned(
                      top: 120.0,
                      left: 50.0,
                      child: Text(
                        "Create your account ",
                        style: GoogleFonts.rubik(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: 155,
                      left: 0,
                      child: Image.asset(
                        'assets/images/signupdesign.png',
                        color: const Color.fromARGB(255, 240, 239, 237),
                      ),
                    ),
                    Positioned(
                      top: 260,
                      left: 45,
                      child: Center(
                        child: SizedBox(
                          width: 300,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {},
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
                                const SizedBox(width: 15),
                                Text(
                                  "CONTINUE WITH GOOGLE",
                                  style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff3F414E),
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
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    print("Go Log In With EMAIL");
                  },
                  child: Text(
                    "OR LOG IN WITH EMAIL",
                    style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffA1A4B2)),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: tfUserNameController,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffF2F3F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "User name",
                      labelStyle: GoogleFonts.rubik(
                          fontSize: 16, fontWeight: FontWeight.normal),
                      suffixIcon: isNameValid
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Username';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: tfMailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffF2F3F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Email",
                      labelStyle: GoogleFonts.rubik(
                          fontSize: 16, fontWeight: FontWeight.normal),
                      suffixIcon: isGmailValid
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid Email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    obscureText: _obscureText,
                    controller: tfPassController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffF2F3F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Password",
                      labelStyle: GoogleFonts.rubik(
                          fontSize: 16, fontWeight: FontWeight.normal),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            _obscureText
                                ? 'assets/images/ic_password_hide.png'
                                : 'assets/images/ic_password_hide.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "I have read the",
                        style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xffA1A4B2)),
                      ),
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: () {
                          print("Go to Privacy Policy");
                        },
                        child: Text(
                          " Privacy Policy",
                          style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff7583CA)),
                        ),
                      ),
                      const SizedBox(width: 100),
                      Checkbox(
                        value: ischeckBox,
                        onChanged: (value) {
                          setState(() {
                            ischeckBox = value ?? false;
                          });
                        },
                        activeColor: const Color(0xff7583CA),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 360,
                  height: 57,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Form alanları doğrulama
                      if (_formKey.currentState!.validate()) {
                        userName = tfUserNameController.text;
                        final email = tfMailController.text;
                        final password = tfPassController.text;
                        try {
                          final userCredentials = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          User? user = FirebaseAuth.instance.currentUser;
                          await user?.updateDisplayName(userName);
                          await user?.reload();
                          user = FirebaseAuth.instance.currentUser;
                          final name = user?.displayName;
                          context.read<UserNameProvider>().setUserName(name!);
                          Navigator.of(context).pushNamed(
                            onBoardViewRoute,
                          );
                        } on FirebaseAuthException catch (e) {
                          String errorMessage;
                          if (e.code == 'weak-password') {
                            errorMessage = 'Weak Password';
                          } else if (e.code == 'email-already-in-use') {
                            errorMessage = 'Email is already in use';
                          } else if (e.code == 'invalid-email') {
                            errorMessage = 'Invalid Email';
                          } else {
                            errorMessage =
                                'An unknown error occurred. Please try again.';
                          }
                          // Hata mesajını gösterme
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8E97FD),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    child: Text(
                      "GET STARTED",
                      style: GoogleFonts.rubik(
                          fontSize: 13.18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffF6F1FB)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(60, 15, 0, 0),
                  child: Row(
                    children: [
                      Text("ALREADY HAVE AN ACCOUNT?",
                          style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffA1A4B2))),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(signInViewRoute);
                        },
                        child: Text(
                          " SIGN IN",
                          style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff8E97FD)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
