import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding4.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Message IA
                Row(
                  children: [
                    Stack(
                      children: [
                        SvgPicture.asset(
                          'lib/features/onboarding/assets/bg1.svg',
                          width: 325,
                          height: 90,
                        ),
                        Positioned(
                          left: 42,
                          top: 18,
                          right: 16,
                          child: const Text(
                            "Merge sort runs in O(n log n) here's why that beats bubble sort every time…",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Syne',
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 72,
                          child: const Text(
                            '12:55',
                            style: TextStyle(
                              color: Color(0xFFF8B878),
                              fontSize: 11,
                              fontFamily: 'Syne',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                
               Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Stack(
                      children: [
                        SvgPicture.asset(
                          'lib/features/onboarding/assets/bg2.svg',
                          width: 240,
                          height: 60,
                        ),
                        Positioned(
                          left: 16,
                          right: 36,
                          top: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Can you make me a 7-day study plan?",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Syne',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Text(
                                    "12:56",
                                    style: TextStyle(
                                      color: Color(0xFFF8B878),
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.done_all,
                                    size: 14,
                                    color: Color(0xFFF8B878),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                 
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'lib/features/onboarding/assets/Recievedmessage.svg',
                    width: 87,
                    height: 36.84,
                  ),
                ),

                const SizedBox(height: 50),

               
                const SizedBox(
                  width: 411,
                  child: Text(
                    ' AI Assistant',
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontSize: 75,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      height: 0.80,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
               const SizedBox(height: 10), Transform.translate( offset: const Offset(-35, 0),
                child: SizedBox(
                   width: 343, 
                   height: 80,
                    child: const Text( 'Get concept explanations, personalized study plans, and weakness analysis tailored to your major.',
                     style: TextStyle( color: Color(0xFFFFFFF0), 
                     fontSize: 16,
                     fontFamily: 'Inter', 
                     fontWeight: FontWeight.w700,
                      height: 1.25, 
               letterSpacing: 0.35, ), ), ), ),



                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding4(),
                      ),
                    );
                  },
                  child: Container(
                    width: 63.99,
                    height: 63.99,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFB284BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 74,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),     const SizedBox(height: 10),
              ],
            ),
              
          ),
        ),
      ),
    );
  }
}