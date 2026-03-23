import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/signup_page.dart';

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

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
                SizedBox(
                  width: 516,
                  height: 120,
                  child: Text(
                    'Deep work.                                              Zero distractions.',
                    style: TextStyle(
                      color: const Color(0xFFFFFFF0),
                      fontSize: 40,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-50, 0),
                  child: SizedBox(
                    width: 343,
                    height: 59,
                    child: Text(
                      'Pomodoro timers, ambient soundscapes, and optional app blocking keep you locked in and productive.',
                      style: TextStyle(
                        color: const Color(0xFFFFFFF0),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Signup_page(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
