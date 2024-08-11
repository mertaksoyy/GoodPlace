import 'package:flutter/material.dart';
import 'package:goodplace/constants/routes.dart';
import 'package:goodplace/models/onboarding/onboarding_items.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final controller = OnboardingItems();
  final pageController = PageController();

  void _onNextButtonPressed() {
    if (pageController.page == controller.items.length - 1) {
      // Kullanıcı son sayfadaysa, Sign In sayfasına yönlendir
      Navigator.pushNamed(context, signInViewRoute);
    } else {
      // Kullanıcı diğer sayfalardaysa, bir sonraki sayfaya geç
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






/*import 'package:flutter/material.dart';
import 'package:goodplace/models/onboarding/onboarding_items.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final controller = OnboardingItems();
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: PageView.builder(
          itemCount: controller.items.length,
          controller: pageController,
          itemBuilder: (context, index) {
            return Column(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/onboardbttn.png'),
                ),
              ],
            );
          },
        ),
      ),

      /*floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xff9DCEFF),
              Color(0xff92A3FD)
            ], // Renk geçişi: 9DCEFF -> 92A3FD
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print("denemelaaaa");
            },
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),*/
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

*/



















/*import 'package:flutter/material.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/images/onboarding2.png'),
          Text(
            "Track Your Habit",
            textAlign: TextAlign.left,
          ),
          const Text(
            "Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
*/
























































