 import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding3.dart';
import 'background.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
              const SizedBox(height: 40),
              _buildTaskCard(
                title: "Grocery shopping app design",
                subtitle: "Market Research",
                time: "10:00 AM",
                status: "Done",
                cardColor: const Color(0xFFC8A2C8),
                circleColor: const Color(0xFFECEBBD),
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                title: "Grocery shopping app design",
                subtitle: "Competitive Analysis",
                time: "12:00 PM",
                status: "In Progress",
                cardColor: const Color(0xFFF8B878),
                circleColor: const Color(0xFFC8A2C8),
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                title: "Uber Eats redesign challenge",
                subtitle: "Create Low-fidelity Wireframe",
                time: "07:00 PM",
                status: "To-do",
                cardColor: const Color(0xFFECEBBD),
                circleColor: const Color(0xFFF8B878),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "All your \ntasks,finally \nin order.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontSize: 57,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Manage deadlines, priorities, and \ncategories in one elegant workspace. \nSync with Google Calendar effortlessly.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Onboarding3(),
                        ),
                      );
                    },
                    child: Container(
                      width: 63.99,
                      height: 63.99,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFA2ADD0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25218600),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 50,
                            offset: Offset(0, 25),
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'lib/features/onboarding/assets/Icon5.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 43,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25218600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5.99,
                        height: 5.99,
                        decoration: ShapeDecoration(
                          color: Colors.white.withAlpha(77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25218600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
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
    Color statusColor = status == "Done"
        ? const Color(0xFF5F33E1)
        : status == "In Progress"
            ? const Color(0xFFFF7D53)
            : const Color(0xFF0087FF);

    Color statusBg = status == "Done"
        ? const Color(0xFFEDE8FF)
        : status == "In Progress"
            ? const Color(0xFFFFE8E1)
            : const Color(0xFFE3F2FF);

    return Container(
      width: 304,
      height: 74,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 8,
            child: Container(
              width: 22,
              height: 21,
              decoration: ShapeDecoration(
                color: circleColor,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 8,
            child: SizedBox(
              width: 170,
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6E6A7C),
                  fontSize: 11,
                  fontFamily: 'Lexend Deca',
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 25,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF24252C),
                fontSize: 14,
                fontFamily: 'Lexend Deca',
              ),
            ),
          ),
          Positioned(
            left: 15,
            bottom: 8,
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontFamily: 'Lexend Deca',
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontFamily: 'Lexend Deca',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}