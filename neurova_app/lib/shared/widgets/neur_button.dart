import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurButton - Primary action button with Lilac gradient
/// Uses Lilac gradient (kLilac → kLilacDeep), Syne Bold text, scale-on-press
class NeurButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const NeurButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<NeurButton> createState() => _NeurButtonState();
}

class _NeurButtonState extends State<NeurButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _scaleController.forward();
  }

  void _onTapUp(_) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const kLilac = Color(0xFFC8B8E8);
    const kLilacDeep = Color(0xFF9A88C0);
    const kLilacMuted = Color(0xFF6A5890);

    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: widget.isLoading ? null : _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? 52,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kLilac, kLilacDeep],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kLilac.withValues(alpha: 0.20),
                blurRadius: 28,
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3d2f6a)),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: kLilacMuted, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kLilacMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Variant button for secondary actions (Amethyst colored)
class NeurSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;

  const NeurSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<NeurSecondaryButton> createState() => _NeurSecondaryButtonState();
}

class _NeurSecondaryButtonState extends State<NeurSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    return GestureDetector(
      onTapDown: widget.isLoading
          ? null
          : (_) {
              _scaleController.forward();
            },
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _scaleController.reverse();
            },
      onTapCancel: widget.isLoading ? null : () => _scaleController.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: nc.amethystSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBEB0D0), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: nc.textSecondary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: nc.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
