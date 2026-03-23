import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding3.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Text(
                      "NEUROVA",
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: -35,
                      top: -30,
                      child: SvgPicture.asset(
                        'lib/features/onboarding/assets/logo.svg',
                        width: 51,
                        height: 39,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                _buildTaskCard(
                  title: "Grocery shopping app design",
                  subtitle: "Market Research",
                  time: "10:00 AM",
                  status: "Done",
                  cardColor: const Color(0xFFC8A2C8),
                  statusBg: const Color(0xFFEDE8FF),
                  titleColor: const Color(0xFF6E6A7C),
                ),
                const SizedBox(height: 16),

                _buildTaskCard(
                  title: "Grocery shopping app design",
                  subtitle: "Competitive Analysis",
                  time: "12:00 PM",
                  status: "In Progress",
                  cardColor: const Color(0xFFF8B878),
                  statusBg: const Color(0xFFFFE9E1),
                  titleColor: const Color(0xFF6E6A7C),
                ),
                const SizedBox(height: 16),

                _buildTaskCard(
                  title: "User Eats redesign challenge",
                  subtitle: "Create Low-fidelity Wireframe",
                  time: "07:00 PM",
                  status: "To-do",
                  cardColor: const Color(0xFFECEBBD),
                  statusBg: const Color(0xFFFFE9E1),
                  titleColor: const Color(0xFF6E6A7C),
                ),

                const SizedBox(height: 24),

                const Text(
                  "All your tasks,\nfinally\nin order.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Manage deadlines, priorities, and\n"
                  "categories in one elegant workspace.\n"
                  "Sync with Google Calendar effortlessly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Onboarding3(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: const Color.fromRGBO(
                              236,
                              235,
                              189,
                              1,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_outlined,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
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
    required Color statusBg,
    required Color titleColor,
  }) {
    Color statusColor = status == "Done"
        ? const Color(0xFF5F33E1)
        : status == "In Progress"
        ? const Color(0xFFFF7D53)
        : const Color(0xFF0087FF);

    return Container(
      width: 304,
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 184,
            height: 11,
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),

          Center(
            child: SizedBox(
              width: 166,
              height: 14,
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.black, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 69,
                height: 11,
                child: Text(
                  time,
                  style: const TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
              SizedBox(
                width: 29,
                height: 9,
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
