import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition for all screens
/// Combines fade and horizontal slide animations
CustomTransitionPage<T> buildTransitionPage<T>({
  required Widget child,
  required String name,
  Duration transitionDuration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage<T>(
    key: ValueKey(name),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        ),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: transitionDuration,
  );
}

/// Staggered animation for screen entry
class ScreenEntryAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int staggerIndex;
  final double slideDistance;

  const ScreenEntryAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.staggerIndex = 0,
    this.slideDistance = 0.06,
  });

  @override
  State<ScreenEntryAnimation> createState() => _ScreenEntryAnimationState();
}

class _ScreenEntryAnimationState extends State<ScreenEntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final delay = (widget.staggerIndex * 0.15).clamp(0.0, 1.0);
    final interval = Interval(
      delay,
      (delay + 0.6).clamp(0.0, 1.0),
      curve: Curves.easeOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: interval),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideDistance),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delay,
          (delay + 0.6).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
