
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding4.dart';
import 'background.dart';
import 'chat_bubbles.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Stack(
            children: [
                            
                            Positioned(
                              left: 19,
                              top: 18 + 48 + 516,
                              child: SizedBox(
                                width: 343,
                                height: 80,
                                child: const Text(
                                  'Get concept explanations, personalized study plans, and weakness analysis tailored to your major.',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFF0),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700, 
                                    fontSize: 15,
                                    height: 20/16,
                                    letterSpacing: 0.35,
                                  ),
                                ),
                              ),
                            ),
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 147 / 2,
                top: 18,
                child: SizedBox(
                  width: 147,
                  height: 48,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: SvgPicture.asset(
                          'lib/features/onboarding/assets/logo.svg',
                          width: 51,
                          height: 39,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 24,
                        child: SizedBox(
                          width: 115,
                          height: 24,
                          child: Text(
                            'NEUROVA',
                            style: const TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 20,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 19,
                top: 110,
                child: ChatBubble(
                  text: "Merge sort runs in O(n log n) here's why that beats bubble sort every time…",
                  time: '12:55',
                  isMe: false,
                ),
              ),
              Positioned(
                right: 19,
                top: 230,
                child: ChatBubble(
                  text: "Can you make me a 7-day study plan?",
                  time: '1:43',
                  isMe: true,
                ),
              ),

              Positioned(
                left: 19,
                top: 330,
                child: TypingBubble(),
              ),
              Positioned(
                left: 19,
            
                top: 18 + 48 + 424,
                child: SizedBox(
                  width: 411,
                  height: 97,
                  child: const Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800, 
                      fontStyle: FontStyle.normal,
                      fontSize: 50,
                      height: 40/50,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 168.96,
                top: 413 + 189 - 12 + 80, 
                child: SizedBox(
                  width: 63.99,
                  height: 63.99,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding4(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color(0xFFB284BE),
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
              
              Positioned(
                top: 413 + 189 - 12 + 80 + 63.99 + 38, 
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 74,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}