import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordSuccessPage extends StatelessWidget {
  const ResetPasswordSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Stack(
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
                  top: -25,
                  child: SvgPicture.asset(
                    'lib/features/onboarding/assets/logo.svg',
                    width: 51,
                    height: 39,
                  ),
                ),
              ],
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your password\nhas been successfully reset',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                          letterSpacing: 0.35,
                        ),
                      ),

                      const SizedBox(height: 60),

                      SizedBox(
                        width: 280,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8A2C8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
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