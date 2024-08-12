import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff8E97FD),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hi, Welcome",
                    style: GoogleFonts.rubik(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffFFECCC)),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "to GoodPlace",
                    style: GoogleFonts.rubik(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xffFFECCC)),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      "Explore the app, Find some peace of mind\nto achieve good habits.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xffEBEAEC))),
                  Image.asset('assets/images/welcomegroup.png'),
                ],
              ),
            ),
            Positioned(
              bottom: 82,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/welcomerectangle.png',
                color: const Color(0xff8C96FF),
              ),
            ),
            Positioned(
              bottom: 92,
              left: 30,
              right: 30,
              child: Container(
                width: 200,
                height: 57,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(signInViewRoute);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEBEAEC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Text(
                    "GET STARTED",
                    style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff3F414E)),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
