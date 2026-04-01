import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class ResetPasswordSuccessPage extends StatelessWidget {
  const ResetPasswordSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
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
                  child: EntryReveal(
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
                              fontSize: 24,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              letterSpacing: -0.2,
                            ),
                          ),

                          const SizedBox(height: 56),

                          SizedBox(
                            width: 300,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC8A2C8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(29),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Back to login",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
