import 'package:flutter/material.dart';

class EntryReveal extends StatelessWidget {
  const EntryReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.offsetY = 24,
  });

  final Widget child;
  final Duration duration;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offsetY),
            child: child,
          ),
        );
      },
    );
  }
}
