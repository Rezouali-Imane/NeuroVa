import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class ConfirmEmailPage extends StatelessWidget {
  final String email;

  const ConfirmEmailPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset(
                    'lib/features/onboarding/assets/fleche2.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text(
                    "Back to login",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ),

              Positioned(
                top: 80,
                left: 0,
                right: 0,
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
                      left: MediaQuery.of(context).size.width / 2 - 80,
                      top: -25,
                      child: SvgPicture.asset(
                        'lib/features/onboarding/assets/logo.svg',
                        width: 51,
                        height: 39,
                      ),
                    ),
                  ],
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: EntryReveal(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),

                          const Text(
                            'Forgot',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const Text(
                            'Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFFFF0),
                              fontSize: 54,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 0.95,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'A password reset link has been sent to\n$email',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFAFAFAF),
                              fontSize: 15,
                              fontFamily: 'Syne',
                              height: 1.4,
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
