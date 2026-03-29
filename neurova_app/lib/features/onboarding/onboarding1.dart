 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Render static gradient logo using flutter_svg.
import 'onboarding2.dart';
import 'background.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 140,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 340,
                  height: 60,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFECEBBD), 
                        Color(0xFFC8A2C8), 
                        Color(0xFFF8B878), 
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Neurova",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 50,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: 210,
            child: Align(
              alignment: Alignment.center,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFECEBBD), 
                    Color(0xFFC8A2C8), 
                    Color(0xFFF8B878), 
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: SvgPicture.asset(
                  'lib/features/onboarding/assets/logo.svg',
                  width: 263,
                  height: 199,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: -12,
            top: 474,
            child: SizedBox(
              width: 367,
              height: 189,
              child: Center(
                child: Text(
                  "Focus.\nLearn.\nThrive.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 60,
                    height: 1.0,
                    letterSpacing: 0.35,
                    color: Color(0xFFFFFFF0), 
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 658,
            child: SizedBox(
              width: 343,
              height: 80,
              child: Text(
                "AI-powered academic companion for\nstudents who want to own their time,\nsilence distractions, and actually achieve.",
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 20/16, 
                  letterSpacing: 0.35,
                  color: Color(0xFFFFFFF0),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            top: 754, 
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 63.99,
                height: 63.99,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding2(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: const Color(0xFFECEBBD),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
            Positioned(
              top: 734 + 63.99 + 58, 
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 381.92,
                  height: 5.99,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 5.99,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5.99,
                        height: 5.99,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5.99,
                        height: 5.99,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}