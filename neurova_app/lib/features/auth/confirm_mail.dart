import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class ConfirmEmailPage extends StatefulWidget {
  final String email;

  const ConfirmEmailPage({super.key, required this.email});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
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
                child: _buildStaggered(
                  index: 0,
                  fromY: 10,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
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
              ),

              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: _buildStaggered(
                  index: 1,
                  fromY: 16,
                  child: const _BrandHeader(),
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

                          _buildStaggered(
                            index: 2,
                            child: const Text(
                              'Forgot',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFFFF0),
                                fontSize: 50,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),

                          _buildStaggered(
                            index: 3,
                            child: const Text(
                              'Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFFFF0),
                                fontSize: 42,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                height: 0.95,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildStaggered(
                            index: 4,
                            child: Text(
                              'A password reset link has been sent to\n${widget.email}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFAFAFAF),
                                fontSize: 15,
                                fontFamily: 'Syne',
                                height: 1.4,
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

  Widget _buildStaggered({
    required int index,
    required Widget child,
    double fromY = 28,
  }) {
    final start = (0.03 + (index * 0.06)).clamp(0.0, 0.88).toDouble();
    final end = (start + 0.24).clamp(0.0, 1.0).toDouble();

    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, animatedChild) {
        final anim = CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, fromY * (1 - anim.value)),
            child: Transform.scale(
              scale: 0.98 + (0.02 * anim.value),
              child: animatedChild,
            ),
          ),
        );
      },
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
            const Positioned(
              left: 32,
              top: 24,
              child: SizedBox(
                width: 115,
                height: 24,
                child: Text(
                  'NEUROVA',
                  style: TextStyle(
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
