import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'setup_profil2.dart';

class SetupProfil extends StatelessWidget {
  const SetupProfil({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            width: 51.0,
                            height: 39.0,
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFF0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Set Up Your Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "How others will see you on Neurova",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _DottedCirclePainter(),
                      ),
                      Container(
                        width: 119,
                        height: 119,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x42A2ADD0),
                        ),
                        child: const Center(
                          child: Text(
                            "IM",
                            style: TextStyle(
                              color: Color(0xFFB284BE),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA2ADD0),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF0B0A15),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'lib/features/onboarding/assets/SVG.svg',
                              width: 14.0,
                              height: 14.0,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Add a profile photo",
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x422A2440),
                      border: Border.all(color: const Color(0x3FECEBBD)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Camera",
                      style: TextStyle(
                        color: Color(0xFFB284BE),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 80,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x422A2440),
                      border: Border.all(color: const Color(0x3FECEBBD)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Gallery",
                      style: TextStyle(
                        color: Color(0xFFB284BE),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: buildField("First Name")),
                  const SizedBox(width: 10),
                  Expanded(child: buildField("Last Name")),
                ],
              ),

              const SizedBox(height: 20),

              buildField("Username", prefix: "@", suffix: "Available"),

              const SizedBox(height: 20),

              buildField(
                "Phone Number",
                initial: "+213",
                prefixIcon: SizedBox(
                  width: 18,
                  height: 18,
                  child: Center(
                    child: SvgPicture.asset(
                      'lib/features/onboarding/assets/phone.svg',
                      width: 22,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9CA3AF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Add Your Bio",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration(
                  hint: "CS student · building things...",
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8A2C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetupProfil2(),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFFFFF0),
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
    );
  }

  static Widget buildField(
    String label, {
    String? prefix,
    String? suffix,
    String? initial,
    Widget? prefixIcon,
  }) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller:
          initial != null ? TextEditingController(text: initial) : null,
      decoration: inputDecoration(
        hint: label,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
      ),
    );
  }

  static InputDecoration inputDecoration({
    String? hint,
    String? prefix,
    String? suffix,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      prefixText: prefix,
      suffixText: suffix,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0x5B2A2440),
      suffixStyle: const TextStyle(color: Color(0xFFECEBBD)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x3FECEBBD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x3FECEBBD)),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA2ADD0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2;
    final circumference = 2 * pi * radius;

    const double dashWidth = 10;
    const double dashSpace = 6.5;

    double current = 0;

    while (current < circumference) {
      final startAngle = (current / radius);
      final endAngle = ((current + dashWidth) / radius);

      final path = Path()
        ..addArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: radius,
          ),
          startAngle,
          endAngle - startAngle,
        );

      canvas.drawPath(path, paint);
      current += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}