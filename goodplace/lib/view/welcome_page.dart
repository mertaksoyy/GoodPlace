import 'package:flutter/material.dart';
import 'package:goodplace/view/sign_up.dart';
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
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























//Gpt nin yaptığı
/*Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9C74F5), // Üstteki gradyan rengi
              Color(0xFF8C61F2), // Alttaki gradyan rengi
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // İllüstrasyon
            Image.asset(
              'assets/images/googlesignin.png', // İllüstrasyonunuzu buraya ekleyin
              height: 250.0,
            ),
            SizedBox(height: 30.0),
            // Hoş geldiniz metni
            Text(
              "Hi, Welcome\nto GoodPlace",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            // Açıklama metni
            Text(
              "Explore the app, Find some peace of mind\nto achieve good habits.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 40.0),
            // "Get Started" butonu
            ElevatedButton(
              onPressed: () {
                // Sonraki sayfaya geçiş veya başka bir işlem yapılabilir
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Yuvarlak köşeler
                ),
                padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: Text(
                "GET STARTED",
                style: TextStyle(
                  color: Colors.deepPurple, // Butonun metin rengi
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ) */





/*Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Hi, Welcome",
            style: GoogleFonts.rubik(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: const Color(0xffFFECCC)),
          ),
          Text(
            "to GoodPlace",
            style: GoogleFonts.roboto(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: Color(0xffFFECCC)),
          ),
          Text(
            "Explore the app, Find some peace of mind",
            style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xffEBEAEC)),
          ),
          Text(
            "to achive good habits.",
            style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xffEBEAEC)),
          ),
        ],
      ), */





/*mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/images/welcometext.png'),
          Image.asset('assets/images/secondwelcometext.png'),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/littlecircle.png',
                  ),
                  Image.asset('assets/images/bigcircle.png'),
                ],
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpPage()));
            },
            child: Text("Get started"),
          )
        ], */
