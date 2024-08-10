import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
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
                onPressed: () {},
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Email address',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, passwordTextFieldHeight, 20, 0),
              child: TextField(
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
                onPressed: () {},
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
                        Navigator.pushNamed(context, signUpViewRoute);
                      },
                      child: Text('SIGN UP')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
