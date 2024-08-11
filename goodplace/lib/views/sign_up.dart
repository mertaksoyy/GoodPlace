import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/views/onboarding_view.dart';
import 'package:goodplace/views/sign_in_view.dart';
import 'package:goodplace/views/welcome_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var tfUserNameController = TextEditingController();
  var tfMailontroller = TextEditingController();
  var tfPassController = TextEditingController();
  bool isNameValid = true;
  bool isGmailValid = true;
  bool isPasswordValid = true;
  bool _obscureText = true;
  bool ischeckBox = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                        Navigator.pushNamed(context, signInViewRoute);
                      },
                      child: Image.asset('assets/images/sign_up_back.png')),
                ),
                Positioned(
                  top: 120.0, // signup.png'nin içinde konumlandırmak için
                  left: 50.0, // signup.png'nin içinde konumlandırmak için
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
                            const SizedBox(
                                width: 15), // İkon ve metin arasındaki boşluk
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
            SizedBox(
              height: 15,
            ),
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
                    //labelText: "User name",
                    labelStyle: GoogleFonts.rubik(
                        fontSize: 16, fontWeight: FontWeight.w300),
                    suffixIcon: isNameValid
                        ? Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: tfMailontroller,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffF2F3F7),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    //labelText: "Gmail",
                    labelStyle: GoogleFonts.rubik(
                        fontSize: 16, fontWeight: FontWeight.w300),
                    suffix: isGmailValid
                        ? Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                obscureText: _obscureText,
                controller: tfPassController,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffF2F3F7),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    //labelText: "Password",
                    labelStyle: GoogleFonts.rubik(
                        fontSize: 16, fontWeight: FontWeight.w300),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/ic_password_hide.png',
                            width: 20,
                            height: 20,
                          ),
                        ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "i have read the",
                    style: GoogleFonts.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xffA1A4B2)),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Go to Privace Policy");
                    },
                    child: Text(
                      " Privace Policy",
                      style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff7583CA)),
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                  Checkbox(
                    value: ischeckBox,
                    onChanged: (value) {
                      setState(() {
                        ischeckBox = !ischeckBox;
                      });
                    },
                    activeColor: const Color(0xff7583CA),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 360,
              height: 57,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, onBoardViewRoute);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8E97FD),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                        print("Go to Sing in Page");
                      },
                      child: Text(
                        " SIGN IN",
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
    );
  }
}
