import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/onboarding/onboarding_items.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final controller = OnboardingItems();
  final pageController = PageController();

  void _onNextButtonPressed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (pageController.page == controller.items.length - 1) {
      prefs.setBool('res', false);
      Navigator.pushNamed(context, mainPageRoute);
    } else {
      // Kullanıcı diğer sayfalardaysa, bir sonraki sayfaya geç
      prefs.setBool('res', true);
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: PageView.builder(
          itemCount: controller.items.length,
          controller: pageController,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(controller.items[index].image),
                    const SizedBox(
                      height: 55,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        controller.items[index].title,
                        style: GoogleFonts.rubik(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff1D1617)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        controller.items[index].description,
                        style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xff7B6F72)),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 20, // Sağdan 20 piksel boşluk
                  bottom: 40, // Alttan 20 piksel boşluk
                  child: GestureDetector(
                    onTap: () {
                      _onNextButtonPressed();
                    },
                    child: Image.asset(
                      'assets/images/onboardbttn.png',
                      width: 60, // Butonun genişliğini belirleyin
                      height: 60, // Butonun yüksekliğini belirleyin
                    ),
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
