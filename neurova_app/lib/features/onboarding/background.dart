import 'package:flutter/material.dart';

class OnboardingBackground extends StatelessWidget {
  final Widget child;
  const OnboardingBackground({super.key, required this.child});

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
                colors: [Color.fromRGBO(90, 128, 250, 0.32), Color.fromRGBO(24, 21, 38, 0.0)],
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
                colors: [Color.fromRGBO(248, 184, 120, 0.28), Color.fromRGBO(24, 21, 38, 0.0)],
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
                colors: [Color.fromRGBO(200, 162, 200, 0.25), Color.fromRGBO(24, 21, 38, 0.0)],
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
                colors: [Color.fromRGBO(240, 147, 251, 0.28), Color.fromRGBO(24, 21, 38, 0.0)],
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
                colors: [Color.fromRGBO(245, 87, 108, 0.28), Color.fromRGBO(24, 21, 38, 0.0)],
                radius: 0.8,
                center: Alignment(0.7, 0.7),
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      
        child,
      ],
    );
  }
}
