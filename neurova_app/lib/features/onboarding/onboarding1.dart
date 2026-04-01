import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'background.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlideY;
  late final Animation<double> _focusFade;
  late final Animation<double> _focusSlideY;
  late final Animation<double> _learnFade;
  late final Animation<double> _learnSlideY;
  late final Animation<double> _thriveFade;
  late final Animation<double> _thriveSlideY;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.389, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.389, curve: Curves.elasticOut),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.111, 0.389, curve: Curves.easeOut),
    );
    _titleSlideY = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.111, 0.389, curve: Curves.easeOut),
      ),
    );

    _focusFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.278, 0.5, curve: Curves.easeOutCubic),
    );
    _focusSlideY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.278, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _learnFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.361, 0.583, curve: Curves.easeOutCubic),
    );
    _learnSlideY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.361, 0.583, curve: Curves.easeOutCubic),
      ),
    );

    _thriveFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.444, 0.667, curve: Curves.easeOutCubic),
    );
    _thriveSlideY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.444, 0.667, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.556, 0.778, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SizedBox.expand(
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
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Opacity(
                          opacity: _titleFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _titleSlideY.value),
                            child: child,
                          ),
                        ),
                        child: const Text(
                          "Neurova",
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      ),
                      child: SvgPicture.asset(
                        'lib/features/onboarding/assets/logo.svg',
                        width: 263,
                        height: 199,
                        colorFilter:
                            const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => Opacity(
                            opacity: _focusFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _focusSlideY.value),
                              child: child,
                            ),
                          ),
                          child: const Text(
                            "Focus.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 60,
                              height: 1.0,
                              letterSpacing: 0.35,
                              color: Color(0xFFFFFFF0),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => Opacity(
                            opacity: _learnFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _learnSlideY.value),
                              child: child,
                            ),
                          ),
                          child: const Text(
                            "Learn.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 60,
                              height: 1.0,
                              letterSpacing: 0.35,
                              color: Color(0xFFFFFFF0),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => Opacity(
                            opacity: _thriveFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _thriveSlideY.value),
                              child: child,
                            ),
                          ),
                          child: const Text(
                            "Thrive.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 60,
                              height: 1.0,
                              letterSpacing: 0.35,
                              color: Color(0xFFFFFFF0),
                            ),
                          ),
                        ),
                      ],
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
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                      opacity: _subtitleFade.value,
                      child: child,
                    ),
                    child: const Text(
                      "AI-powered academic companion for\nstudents who want to own their time,\nsilence distractions, and actually achieve.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 20 / 16,
                        letterSpacing: 0.35,
                        color: Color(0xFFFFFFF0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}