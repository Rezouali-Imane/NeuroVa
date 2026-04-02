import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../onboarding/background.dart';
import '../../shared/widgets/entry_reveal.dart';

class SetupProfile3Page extends StatefulWidget {
  const SetupProfile3Page({super.key});

  @override
  State<SetupProfile3Page> createState() => _SetupProfile3PageState();
}

class _SetupProfile3PageState extends State<SetupProfile3Page> {
  bool _focusReminders = true;
  bool _faithMode = false;
  bool _notifications = true;
  bool _hapticFeedback = true;
  bool _focusShield = true;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentStep = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: EntryReveal(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxHeight / 910).clamp(0.80, 1.0);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Transform.scale(
                      alignment: Alignment.topCenter,
                      scale: scale,
                      child: SizedBox(
                          width: constraints.maxWidth / scale,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 160,
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
                                        left: 30,
                                        top: 28,
                                        child: Text(
                                          'NEUROVA',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFF0),
                                            fontSize: 15,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStepIndicator(_currentStep),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(
                              width: 299,
                              child: Text(
                                'Almost there !',
                                style: TextStyle(
                                  color: Color(0xFFFFFFF0),
                                  fontSize: 45,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w900,
                                  height: 1.13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Customize your Neurova experience',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 47),
                            Expanded(
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                children: [
                                  const SectionTitle(title: 'FOCUS'),
                                  const SizedBox(height: 6),
                                  SettingTile(
                                    title: 'Focus Reminders',
                                    subtitle: 'Daily study reminders',
                                    icon: Icons.alarm_outlined,
                                    value: _focusReminders,
                                    onChanged: (value) {
                                      setState(() {
                                        _focusReminders = value;
                                      });
                                    },
                                  ),
                                  SettingTile(
                                    title: 'Faith Mode',
                                    subtitle: 'Include prayer blocks in plans',
                                    icon: Icons.star_border,
                                    value: _faithMode,
                                    onChanged: (value) {
                                      setState(() {
                                        _faithMode = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  const SectionTitle(title: 'NOTIFICATIONS'),
                                  const SizedBox(height: 6),
                                  SettingTile(
                                    title: 'Notifications',
                                    subtitle: 'Focus reminders & alerts',
                                    icon: Icons.notifications_none,
                                    value: _notifications,
                                    onChanged: (value) {
                                      setState(() {
                                        _notifications = value;
                                      });
                                    },
                                  ),
                                  SettingTile(
                                    title: 'Haptic Feedback',
                                    subtitle: 'Vibrations on actions',
                                    icon: Icons.vibration_outlined,
                                    value: _hapticFeedback,
                                    onChanged: (value) {
                                      setState(() {
                                        _hapticFeedback = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  const SectionTitle(
                                    title: 'DIGITAL DISCIPLINE',
                                  ),
                                  const SizedBox(height: 6),
                                  FocusShieldCard(
                                    value: _focusShield,
                                    onChanged: (value) {
                                      setState(() {
                                        _focusShield = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 67.99,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    188,
                                    241,
                                    224,
                                    228,
                                  ),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Start Learning',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(
                                      'lib/features/onboarding/assets/fleche.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == currentPage;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opacity: isActive ? 1.0 : 0.85,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.30),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
          ),
        );
      }),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontFamily: 'Syne',
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.8,
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          NurovaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class FocusShieldCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const FocusShieldCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1F3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB284BE).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFB284BE).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.shield_outlined,
                size: 18,
                color: const Color(0xFFB284BE),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Shield',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Blocking 4 apps right now',
                  style: TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          NurovaToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class NurovaToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NurovaToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? const Color(0xFFB284BE)
              : Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: value
                ? const Color(0xFFB284BE)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
