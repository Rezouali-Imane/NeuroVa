import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SetupProfile3Page extends StatelessWidget {
  const SetupProfile3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                            left: 27,
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
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFF0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 299,
                  child: Text(
                    'Almost there !',
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontSize: 32,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      height: 1.13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Customize your Neurova experience",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                const SectionTitle(title: "FOCUS"),
                const SizedBox(height: 12),
                const SettingTile(
                  title: "Focus Reminders",
                  subtitle: "Daily study reminders",
                  icon: 'Icon6.svg',
                ),
                const SettingTile(
                  title: "Faith Mode",
                  subtitle: "Include prayer blocks in plans",
                  icon: 'Icon7.svg',
                ),
                const SizedBox(height: 20),
                const SectionTitle(title: "NOTIFICATIONS"),
                const SizedBox(height: 12),
                const SettingTile(
                  title: "Notifications",
                  subtitle: "Focus reminders & alerts",
                  icon: 'Icon8.svg',
                ),
                const SettingTile(
                  title: "Haptic Feedback",
                  subtitle: "Vibrations on actions",
                  icon: 'Icon9.svg',
                ),
                const SizedBox(height: 20),
                const SectionTitle(title: "DIGITAL DISCIPLINE"),
                const SizedBox(height: 12),
                const FocusShieldCard(),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC8A2C8), Color(0xFFB284BE)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Start Learning",
                      style: TextStyle(
                        color: Color(0xFFFFFFF0),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }
}

class SettingTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String icon;

  const SettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x5B2A2440),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8.5),
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/onboarding/assets/${widget.icon}',
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: (val) {
              setState(() {
                active = val;
              });
            },
            activeColor: const Color(0xFFB284BE),
          ),
        ],
      ),
    );
  }
}

class FocusShieldCard extends StatefulWidget {
  const FocusShieldCard({super.key});

  @override
  State<FocusShieldCard> createState() => _FocusShieldCardState();
}

class _FocusShieldCardState extends State<FocusShieldCard> {
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB284BE).withOpacity(0.2),
            const Color(0xFF8C64A0).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33B284BE)),
      ),
      child: Row(
        children: [
          Container(
            width: 47.99,
            height: 47.99,
            padding: const EdgeInsets.only(left: 12.99, right: 13),
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.0, 0.0),
                end: Alignment(1.0, 1.0),
                colors: [Color(0xFFB284BE), Color(0xFF9B6AAB)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x47B284BE),
                  blurRadius: 8.16,
                  offset: Offset(0, 0),
                )
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'lib/features/onboarding/assets/Icon10.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Focus Shield",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Blocking 4 apps right now",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            onChanged: (val) {
              setState(() {
                active = val;
              });
            },
            activeColor: const Color(0xFFB284BE),
          ),
        ],
      ),
    );
  }
}