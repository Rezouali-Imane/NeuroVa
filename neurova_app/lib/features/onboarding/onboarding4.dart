 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/signup_page.dart';
import 'background.dart';

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
              //--- Ellipses superposées au centre ---
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ellipse 2 en dessous
                    SvgPicture.asset(
                      'lib/features/onboarding/assets/ellipse42.svg',
                      width: 308,
                      height: 308,
                    ),
                    // Ellipse 1 au-dessus (comme tu voulais)
                    SvgPicture.asset(
                      'lib/features/onboarding/assets/ellipse41.svg',
                      width: 308,
                      height: 308,
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    //--- Logo NEUROVA ---
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          const Text(
                            "NEUROVA",
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            left: -35,
                            top: -30,
                            child: SvgPicture.asset(
                              'lib/features/onboarding/assets/logo.svg',
                              width: 51,
                              height: 39,
                              placeholderBuilder: (context) =>
                                  const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 300),

                    //--- Texte principal ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        child: const Text(
                          'Deep work. Zero distractions.',
                          style: TextStyle(
                            color: Color(0xFFFFFFF0),
                            fontSize: 40,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    //--- Description ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        child: const Text(
                          'Pomodoro timers, ambient soundscapes, and optional app blocking keep you locked in and productive.',
                          style: TextStyle(
                            color: Color(0xFFFFFFF0),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    //--- Bouton GET STARTED ---
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 174,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8B878), Color(0xFFF5576C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'GET STARTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

