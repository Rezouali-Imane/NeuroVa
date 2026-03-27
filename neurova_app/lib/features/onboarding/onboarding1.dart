 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding2.dart'; 

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),

              
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: const [
                    Color.fromRGBO(236, 235, 189, 1),
                    Color.fromRGBO(200, 162, 200, 1),
                    Color.fromRGBO(248, 184, 120, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  "Neurova",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SvgPicture.asset(
                'lib/features/onboarding/assets/Vector.svg',
                width: 263,
                height: 199,
              ),

              const SizedBox(height: 50),

               
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Focus.\nLearn.\nThrive.",
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w700,
                        height: 0.95,
                        color: Color(0xFFFFFFF0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "AI-powered academic companion for students "

                      "\nwho want to own their time, \nsilence distractions, "
                      "and actually achieve.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: 0.35,
                        color: Color(0xFFFFFFF0),
                      ),
                    ),

                    const SizedBox(height: 30),

                     
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Onboarding2(),
                            ),
                          );
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEBBD),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'lib/features/onboarding/assets/Icon5.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      
                        Container(
                          width: 32,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Point 1
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Point 2
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}