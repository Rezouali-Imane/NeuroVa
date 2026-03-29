import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding3.dart';
import 'background.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OnboardingBackground(
        child: SafeArea(
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
              Positioned(
                left: 49,
                top: 112,
                child: SizedBox(
                  width: 304,
                  height: 246, 
                  child: Column(
                    children: [
                      _buildTaskCard(
                        title: 'Grocery shopping app design',
                        subtitle: 'Market Research',
                        time: '10:00 AM',
                        status: 'Done',
                        cardColor: const Color(0xFFC8A2C8),
                        circleColor: const Color(0xFFF5F0B6),
                      ),
                      const SizedBox(height: 12),
                      _buildTaskCard(
                        title: 'Grocery shopping app design',
                        subtitle: 'Competitive Analysis',
                        time: '12:00 PM',
                        status: 'In Progress',
                        cardColor: const Color(0xFFF8B878),
                        circleColor: const Color(0xFFFFE0B0),
                      ),
                      const SizedBox(height: 12),
                      _buildTaskCard(
                        title: 'Uber Eats redesign challenge',
                        subtitle: 'Create Low-fidelity Wireframe',
                        time: '07:00 PM',
                        status: 'To-do',
                        cardColor: const Color(0xFFECEBBD),
                        circleColor: const Color(0xFFF8B878),
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
                  child: Text(
                    'All your\ntasks, finally\nin order.',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800, 
                      fontStyle: FontStyle.normal,
                      fontSize: 40,
                      height: 60/40,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              
              Positioned(
                left: 18, 
                top: 413 + 189 - 12, 
                child: SizedBox(
                  width: 400,
                  child: Text(
                    'Manage deadlines, priorities,and\ncategories in one elegant workspace.\nSync with Google Calendar effortlessly.',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700, 
                      fontSize: 16,
                      height: 20/16,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: (413 + 189 - 12) + 80 + 16, 
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 63.99,
                    height: 63.99,
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
                        backgroundColor: const Color(0xFFD2C7F2),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_outlined,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              
              Positioned(
                top: 860, 
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 381.92,
                    height: 5.99,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 5.99,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 5.99,
                          height: 5.99,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 5.99,
                          height: 5.99,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                Positioned(
                  top: 413 + 189 - 12 + 80 + 63.99 + 38, 
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 57, // 43 + 8 + 6
                      height: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 43,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25218600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.3),
                              borderRadius: BorderRadius.circular(25218600),
                            ),
                          ),
                        ],
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
          // Title
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