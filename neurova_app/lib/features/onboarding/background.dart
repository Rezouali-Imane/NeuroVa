import 'package:flutter/material.dart';

/// Reusable onboarding background widget.
class OnboardingBackground extends StatelessWidget {
  final Widget child;
  const OnboardingBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(color: const Color(0xFF181526)),
        // Top-left purple radial gradient
        Positioned(
          left: -size.width * 0.28,
          top: -size.height * 0.22,
          child: Container(
            width: size.width * 1.05,
            height: size.height * 0.6,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFF5A80FA).withOpacity(0.32), const Color(0xFF181526).withOpacity(0.0)],
                radius: 0.85,
                center: Alignment(-0.7, -0.7),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Top-right orange radial gradient
        Positioned(
          right: -size.width * 0.22,
          top: size.height * 0.04,
          child: Container(
            width: size.width * 0.8,
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFFF8B878).withOpacity(0.28), const Color(0xFF181526).withOpacity(0.0)],
                radius: 0.8,
                center: Alignment(0.7, -0.2),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Center-left purple radial gradient
        Positioned(
          left: -size.width * 0.22,
          top: size.height * 0.36,
          child: Container(
            width: size.width * 0.8,
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFFC8A2C8).withOpacity(0.25), const Color(0xFF181526).withOpacity(0.0)],
                radius: 0.8,
                center: Alignment(-0.7, 0.2),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Bottom-left pink radial gradient
        Positioned(
          left: -size.width * 0.22,
          bottom: -size.height * 0.16,
          child: Container(
            width: size.width * 0.9,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFFF093FB).withOpacity(0.28), const Color(0xFF181526).withOpacity(0.0)],
                radius: 0.8,
                center: Alignment(-0.7, 0.7),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Bottom-right orange/pink radial gradient
        Positioned(
          right: -size.width * 0.22,
          bottom: -size.height * 0.16,
          child: Container(
            width: size.width * 0.9,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0xFFF5576C).withOpacity(0.28), const Color(0xFF181526).withOpacity(0.0)],
                radius: 0.8,
                center: Alignment(0.7, 0.7),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Foreground child widget
        child,
      ],
    );
  }
}
