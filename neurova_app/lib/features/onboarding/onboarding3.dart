
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'background.dart';
import 'chat_bubbles.dart';

class Onboarding3 extends StatefulWidget {
  const Onboarding3({super.key});

  @override
  State<Onboarding3> createState() => _Onboarding3State();
}

class _Onboarding3State extends State<Onboarding3>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedHeadline(Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, headlineChild) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
        );
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - anim.value)),
            child: headlineChild,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle(Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, subtitleChild) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.60, 0.85, curve: Curves.easeIn),
        );
        return Opacity(
          opacity: anim.value,
          child: subtitleChild,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Logo + NEUROVA text (match onboarding2)
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
              // Chat message bubbles (custom Flutter widgets for animation)
              // First message (left, dark, with tail)
              Positioned(
                left: 50,
                top: 142,
                child: ChatBubble(
                  text: "Merge sort runs in O(n log n)\n here's why that beats\n bubble sort every time…",
                  time: '12:55',
                  isMe: false,
                  delay: Duration.zero,
                ),
              ),
              // Second message (right, purple, with tail)
              Positioned(
                right: 50,
                top: 262,
                child: ChatBubble(
                  text: "Can you make me a 7-day\n study plan?",
                  time: '1:43',
                  isMe: true,
                  delay: Duration(milliseconds: 1100),
                ),
              ),
              // Typing indicator (left, three dots)
              Positioned(
                left: 50,
                top: 362,
                child: TypingBubble(
                  delay: Duration(milliseconds: 2300),
                ),
              ),
              // Big text (201px above indicator, 424px below NEUROVA text)
              Positioned(
                left: 19,
                // NEUROVA text top (18) + height (48) + 424 = 490
                // or indicator top - 201
                top: 18 + 48 + 424,
                child: SizedBox(
                  width: 411,
                  height: 97,
                  child: _buildAnimatedHeadline(
                    const Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Color(0xFFFFFFF0),
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800, // ExtraBold
                        fontStyle: FontStyle.normal,
                        fontSize: 50,
                        height: 40 / 50,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 18 + 48 + 516,
                child: SizedBox(
                  width: 343,
                  height: 80,
                  child: _buildAnimatedSubtitle(
                    const Text(
                      'Get concept explanations, personalized study plans, and weakness analysis tailored to your major.',
                      style: TextStyle(
                        color: Color(0xFFFFFFF0),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700, // Bold
                        fontSize: 17,
                        height: 20 / 16,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),
              ),
              // ...existing code...
            ],
          ),
        ),
      ),
    );
  }
}