import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'onboarding2.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        children: [
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.05,
            child: SizedBox(
              width: screenWidth * 0.6,
              height: screenHeight * 0.08,
              child: Text(
                "Neurova",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  foreground: ui.Paint()
                    ..shader =
                        LinearGradient(
                          colors: const [
                            Color.fromRGBO(236, 235, 189, 1),
                            Color.fromRGBO(200, 162, 200, 1),
                            Color.fromRGBO(248, 184, 120, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          Rect.fromLTWH(
                            0,
                            0,
                            screenWidth * 0.6,
                            screenHeight * 0.08,
                          ),
                        ),
                ),
              ),
            ),
          ),

          Positioned(
            left: screenWidth * 0.15,
            top: screenHeight * 0.15,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity().scaled(-1.0, 1.0),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color.fromRGBO(236, 235, 189, 1),
                    Color.fromRGBO(200, 162, 200, 1),
                    Color.fromRGBO(248, 184, 120, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: SvgPicture.asset(
                  'lib/features/onboarding/assets/logo.svg',
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.3,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.5,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Focus.\nLearn.\nThrive.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                    letterSpacing: 0.35,
                    color: const Color.fromRGBO(255, 255, 240, 1),
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                SizedBox(
                  width: screenWidth * 0.55,
                  child: const Text(
                    "AI-powered academic companion for students "
                    "who want to own their time, silence distractions, "
                    "and actually achieve.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 20 / 16,
                      letterSpacing: 0.3516,
                      color: Color.fromRGBO(255, 255, 240, 1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
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
                            backgroundColor: const Color.fromRGBO(
                              236,
                              235,
                              189,
                              1,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_outlined,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}