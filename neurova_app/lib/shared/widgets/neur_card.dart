import 'package:flutter/material.dart';

/// NeurCard - Base card widget with consistent styling
/// Uses kSurface background, radius 20, optional glow shadow, press scale animation
class NeurCard extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double borderRadius;
  final BoxDecoration? decoration;

  const NeurCard({
    super.key,
    required this.child,
    this.glowColor,
    this.onTap,
    this.padding,
    this.borderRadius = 20,
    this.decoration,
  });

  @override
  State<NeurCard> createState() => _NeurCardState();
}

class _NeurCardState extends State<NeurCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap != null) {
      _scaleController.forward();
    }
  }

  void _onTapUp(_) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding,
          decoration: widget.decoration ??
              BoxDecoration(
                color: nc.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.glowColor != null
                    ? [
                        BoxShadow(
                          color: widget.glowColor!,
                          blurRadius: 28,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// NeuropaColors ThemeExtension for accessing semantic colors
@immutable
class NeuropaColors extends ThemeExtension<NeuropaColors> {
  const NeuropaColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.lilacSurface,
    required this.amethystSurface,
    required this.blueSurface,
    required this.lemonSurface,
    required this.caramelSurface,
    required this.divider,
  });

  final Color background, surface, surfaceElevated;
  final Color textPrimary, textSecondary, textMuted;
  final Color lilacSurface, amethystSurface, blueSurface;
  final Color lemonSurface, caramelSurface;
  final Color divider;

  // Dark mode
  static const dark = NeuropaColors(
    background: Color(0xFF0D0D14),
    surface: Color(0xFF16161F),
    surfaceElevated: Color(0xFF1E1E2C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8B0C8),
    textMuted: Color(0xFF6A6480),
    lilacSurface: Color(0x1AC8B8E8), // 10% Lilac on dark
    amethystSurface: Color(0x1ABEB0D0), // 10% Amethyst on dark
    blueSurface: Color(0x15B8D4E8), // 8% Blue on dark
    lemonSurface: Color(0x15F5EFC0), // 8% Lemon on dark
    caramelSurface: Color(0x15E8C898), // 8% Caramel on dark
    divider: Color(0x14FFFFFF),
  );

  // Light mode
  static const light = NeuropaColors(
    background: Color(0xFFF5F2FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0ECFA),
    textPrimary: Color(0xFF1A1030),
    textSecondary: Color(0xFF6A5888),
    textMuted: Color(0xFF9888B8),
    lilacSurface: Color(0xFFEAE5F5),
    amethystSurface: Color(0xFFE8E2F5),
    blueSurface: Color(0xFFDDE8F2),
    lemonSurface: Color(0xFFF8F4D8),
    caramelSurface: Color(0xFFF5ECD8),
    divider: Color(0x18C8B8E8),
  );

  @override
  NeuropaColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? lilacSurface,
    Color? amethystSurface,
    Color? blueSurface,
    Color? lemonSurface,
    Color? caramelSurface,
    Color? divider,
  }) =>
      NeuropaColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        lilacSurface: lilacSurface ?? this.lilacSurface,
        amethystSurface: amethystSurface ?? this.amethystSurface,
        blueSurface: blueSurface ?? this.blueSurface,
        lemonSurface: lemonSurface ?? this.lemonSurface,
        caramelSurface: caramelSurface ?? this.caramelSurface,
        divider: divider ?? this.divider,
      );

  @override
  NeuropaColors lerp(NeuropaColors? other, double t) => this;
}
