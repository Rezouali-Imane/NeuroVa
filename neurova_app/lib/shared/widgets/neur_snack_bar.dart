import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurSnackBar - Custom animated snackbar (not Material default)
enum SnackType { success, error, info, warning }

class NeurSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NeurSnackBarWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
          onDismiss?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _NeurSnackBarWidget extends StatefulWidget {
  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NeurSnackBarWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_NeurSnackBarWidget> createState() => _NeurSnackBarWidgetState();
}

class _NeurSnackBarWidgetState extends State<_NeurSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (widget.type) {
      case SnackType.success:
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.9);
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackType.error:
        backgroundColor = const Color(0xFFEF5350).withOpacity(0.9);
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackType.warning:
        backgroundColor = const Color(0xFFFFC107).withOpacity(0.9);
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackType.info:
        backgroundColor = nc.surface;
        textColor = nc.textPrimary;
        icon = Icons.info;
        break;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
          child: GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                widget.onDismiss();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
