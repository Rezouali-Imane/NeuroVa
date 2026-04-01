import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../shared/widgets/entry_reveal.dart';
import 'background.dart';

class Onboarding4 extends StatelessWidget {
  const Onboarding4({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: EntryReveal(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'lib/features/onboarding/assets/logo.svg',
                          width: 46,
                          height: 34,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'NEUROVA',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'lib/features/onboarding/assets/ellipse42.svg',
                        width: 308,
                        height: 308,
                      ),
                      SvgPicture.asset(
                        'lib/features/onboarding/assets/ellipse41.svg',
                        width: 308,
                        height: 308,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
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
                          height: 1.2,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

