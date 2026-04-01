import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'background.dart';
import '../../shared/widgets/entry_reveal.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _floatController.repeat(reverse: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    const entranceStarts = [0.0, 0.2, 0.4];
    const entranceEnds = [0.5, 0.7, 0.9];

    const floatStarts = [0.0, 0.13, 0.26];
    const floatAmplitudes = [8.0, 6.0, 9.0];

    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, entranceChild) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: Interval(
            entranceStarts[index],
            entranceEnds[index],
            curve: Curves.easeOutCubic,
          ),
        );

        return AnimatedBuilder(
          animation: _floatController,
          child: entranceChild,
          builder: (context, floatChild) {
            final floatAnim = CurvedAnimation(
              parent: _floatController,
              curve: Interval(
                floatStarts[index],
                1.0,
                curve: Curves.easeInOut,
              ),
            );

            return Opacity(
              opacity: anim.value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  (50 * (1 - anim.value)) + (-floatAmplitudes[index] * floatAnim.value),
                ),
                child: Transform.scale(
                  scale: 0.92 + (0.08 * anim.value),
                  child: floatChild,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedHeadlineLine({
    required String text,
    required double start,
    required double end,
  }) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Color(0xFFFFFFF0),
          fontFamily: 'Syne',
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.normal,
          fontSize: 40,
          height: 60 / 40,
          letterSpacing: 0.35,
        ),
      ),
      builder: (context, child) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - anim.value)),
            child: child,
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
          child: EntryReveal(
            child: Stack(
              children: [
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
                ),
                Positioned(
                  left: 49,
                  top: 112,
                  child: SizedBox(
                    width: 304,
                    height: 246,
                    child: Column(
                      children: [
                        _buildAnimatedCard(
                          index: 0,
                          child: _buildTaskCard(
                            title: 'Grocery shopping app design',
                            subtitle: 'Market Research',
                            time: '10:00 AM',
                            status: 'Done',
                            cardColor: const Color(0xFFC8A2C8),
                            circleColor: const Color(0xFFF5F0B6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          index: 1,
                          child: _buildTaskCard(
                            title: 'Grocery shopping app design',
                            subtitle: 'Competitive Analysis',
                            time: '12:00 PM',
                            status: 'In Progress',
                            cardColor: const Color(0xFFF8B878),
                            circleColor: const Color(0xFFFFE0B0),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          index: 2,
                          child: _buildTaskCard(
                            title: 'Uber Eats redesign challenge',
                            subtitle: 'Create Low-fidelity Wireframe',
                            time: '07:00 PM',
                            status: 'To-do',
                            cardColor: const Color(0xFFECEBBD),
                            circleColor: const Color(0xFFF8B878),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 413,
                  child: SizedBox(
                    width: 400,
                    height: 189,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedHeadlineLine(
                          text: 'All your',
                          start: 0.0,
                          end: 0.35,
                        ),
                        _buildAnimatedHeadlineLine(
                          text: 'tasks, finally',
                          start: 0.15,
                          end: 0.50,
                        ),
                        _buildAnimatedHeadlineLine(
                          text: 'in order.',
                          start: 0.30,
                          end: 0.65,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 413 + 189 - 12,
                  child: SizedBox(
                    width: 400,
                    child: _buildAnimatedSubtitle(
                      const Text(
                        'Manage deadlines, priorities,and\ncategories in one elegant workspace.\nSync with Google Calendar effortlessly.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFFFFFFF0),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          height: 20 / 16,
                          letterSpacing: 0.35,
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
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color cardColor,
    required Color circleColor,
  }) {
    final Color statusColor = status == 'Done'
        ? const Color(0xFF5F33E1)
        : status == 'In Progress'
            ? const Color(0xFFFF7D53)
            : const Color(0xFF0087FF);

    final Color statusBg = status == 'Done'
        ? const Color(0xFFEDE8FF)
        : status == 'In Progress'
            ? const Color(0xFFFFE8E1)
            : const Color(0xFFE3F2FF);

    return Container(
      width: 304,
      height: 74,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 271,
            top: 9,
            child: Container(
              width: 22,
              height: 21,
              decoration: BoxDecoration(
                color: cardColor == const Color(0xFFC8A2C8)
                    ? Color(0xFFECEBBD)
                    : cardColor == const Color(0xFFF8B878)
                        ? Color(0xFFC8A2C8)
                        : Color(0xFFF8B878),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 10,
            right: 54,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8E8396),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 10 + 11 + 6,
            right: 90,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF211E26),
                fontSize: 14,
                fontFamily: 'Lexend Deca',
                fontWeight: FontWeight.w400,
                height: 1.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 10 + 11 + 6 + 14 + 6,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFF4B4952),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 10 + 11 + 6 + 14 + 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
