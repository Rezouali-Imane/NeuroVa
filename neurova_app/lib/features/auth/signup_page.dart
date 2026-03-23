 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Signup_page extends StatelessWidget {
  const Signup_page ({super.key});

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
                          'lib/features/onboarding/logo.svg',
                          width: 51,
                          height: 39,
                           
                          placeholderBuilder: (context) => const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
    width: 345.84,
    height: 55.98,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 11.99,
        children: [
            Container(
                width: 20,
                height: 20,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Stack(),
            ),
            Expanded(
                child: Container(
                    height: 23.99,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Text(
                                'Full name',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.40),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.31,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        Container(
    width: 345.84,
    height: 55.98,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 11.99,
        children: [
            Container(
                width: 20,
                height: 20,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Stack(),
            ),
            Expanded(
                child: Container(
                    height: 23.99,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Text(
                                'Email address',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.40),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.31,
                                ),
                            ),
                        ],
                    ),
                ),
           
            ),
        ],
    ),
)
        
        ],
    ),
)

              ],
            ),
          ),
        ),
      ),
    );
  }
}

