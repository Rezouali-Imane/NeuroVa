import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'background.dart';

class Onboarding4 extends StatefulWidget {
  const Onboarding4({super.key});

  @override
  State<Onboarding4> createState() => _Onboarding4State();
}

class _Onboarding4State extends State<Onboarding4>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _arcProgress;
  late final Animation<double> _timeOpacity;
  late final Animation<double> _timeScale;
  late final Animation<double> _pomodoroOpacity;
  late final Animation<double> _headline1Opacity;
  late final Animation<double> _headline1TranslateY;
  late final Animation<double> _headline2Opacity;
  late final Animation<double> _headline2TranslateY;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _arcProgress = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _timeOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );
    _timeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _pomodoroOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
    );

    _headline1Opacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
    );
    _headline1TranslateY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _headline2Opacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic),
    );
    _headline2TranslateY = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.75, 0.90, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.80, 1.0, curve: Curves.elasticOut),
      ),
    );


    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const _BrandHeader(),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * (308 / 390),
                    height: MediaQuery.of(context).size.width * (308 / 390),
                    child: AnimatedBuilder(
                      animation: _arcProgress,
                      child: const SizedBox.expand(),
                      builder: (context, circleBase) {
                        final circleSize = MediaQuery.of(context).size.width * (308 / 390);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(circleSize, circleSize),
                              painter: PomodoroArcPainter(progress: _arcProgress.value),
                              child: circleBase,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: Listenable.merge([_timeOpacity, _timeScale]),
                                  child: const Text(
                                    '32:10',
                                    style: TextStyle(
                                      color: Color(0xFFB284BE),
                                      fontSize: 60,
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _timeOpacity.value,
                                      child: Transform.scale(
                                        scale: _timeScale.value,
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _pomodoroOpacity,
                                  child: const Text(
                                    'pomodoro',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _pomodoroOpacity.value,
                                      child: child,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: Listenable.merge([_headline1Opacity, _headline1TranslateY]),
                  child: const Text(
                    'Deep work.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: const Offset(0, -14),
                      child: Opacity(
                        opacity: _headline1Opacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _headline1TranslateY.value),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: Listenable.merge([_headline2Opacity, _headline2TranslateY]),
                  child: const Text(
                    'Zero\ndistractions.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: const Offset(0, -14),
                      child: Opacity(
                        opacity: _headline2Opacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _headline2TranslateY.value),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _subtitleOpacity,
                  child: const Text(
                    'Pomodoro timers, ambient soundscapes, and optional app blocking keep you locked in and productive.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: const Offset(0, -14),
                      child: Opacity(
                        opacity: _subtitleOpacity.value,
                        child: child,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),
                Center(
                  child: AnimatedBuilder(
                    animation: _buttonScale,
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF5D9A0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'get started',
                        style: TextStyle(
                          color: Color(0xFF1A1025),
                          fontSize: 16,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _buttonScale.value,
                        child: child,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
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
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
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
    );
  }
}

class PomodoroArcPainter extends CustomPainter {
  PomodoroArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final blurPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius, blurPaint);

    const double startAngle = -65 * pi / 180;
    const double sweepAngle = 2 * pi * 0.62;
    final activeSweep = sweepAngle * progress;
    final tipAngle = startAngle + activeSweep;

    final arcGradient = const LinearGradient(
      begin: Alignment(0.72, 0.63),
      end: Alignment(0.45, 0.70),
      colors: [
        Color(0xFFECEBBD),
        Color(0xFFE6DEBE),
        Color(0xFFDCCFC3),
        Color(0xFFD4C2CD),
        Color(0xFFCFB7D3),
        Color(0xFFC8A2C8),
      ],
      stops: [0.0, 0.18, 0.42, 0.66, 0.84, 1.0],
    );

    final baseArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..shader = arcGradient.createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      activeSweep,
      false,
      baseArcPaint,
    );

    final tipSweep = activeSweep.clamp(0.0, 0.5);
    if (tipSweep > 0) {
      final tipArcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..shader = arcGradient.createShader(rect);

      canvas.drawArc(
        rect,
        tipAngle - tipSweep,
        tipSweep,
        false,
        tipArcPaint,
      );
    }

    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);

    if (progress > 0.05) {
      final tipOffset = Offset(tipX, tipY);

      canvas.drawCircle(
        tipOffset,
        12,
        Paint()
          ..color = const Color(0xFFF6F0D6).withOpacity(0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      canvas.drawCircle(
        tipOffset,
        5.25,
        Paint()..color = const Color(0xFFF6F0D6),
      );
    }
  }

  @override
  bool shouldRepaint(PomodoroArcPainter old) {
    return old.progress != progress;
  }
}

