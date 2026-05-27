import 'package:flutter/material.dart';
import 'neur_card.dart';

/// NeurThemeToggle - Custom animated toggle for theme selection
/// Pill shape, 56×28px, animated transition between dark and light modes
class NeurThemeToggle extends StatefulWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const NeurThemeToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  State<NeurThemeToggle> createState() => _NeurThemeToggleState();
}

class _NeurThemeToggleState extends State<NeurThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.dark;
    const kLilac = Color(0xFFC8B8E8);

    final isDark = widget.currentMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        widget.onChanged(isDark ? ThemeMode.light : ThemeMode.dark);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 56,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? nc.surface : const Color(0xFFEAE5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kLilac.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: kLilac.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background labels (animated opacity)
            Positioned(
              left: 6,
              top: 4,
              child: AnimatedOpacity(
                opacity: isDark ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(Icons.dark_mode,
                    size: 16, color: nc.textSecondary),
              ),
            ),
            Positioned(
              right: 6,
              top: 4,
              child: AnimatedOpacity(
                opacity: !isDark ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(Icons.light_mode,
                    size: 16, color: const Color(0xFF6A5890)),
              ),
            ),
            // Animated thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isDark ? 2 : 28,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 14,
                    color: kLilac,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// NeurThemeToggleRow - Toggle embedded in a settings-style row
class NeurThemeToggleRow extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;
  final String label;

  const NeurThemeToggleRow({
    super.key,
    required this.currentMode,
    required this.onChanged,
    this.label = 'Light mode',
  });

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: nc.textPrimary,
            ),
          ),
          NeurThemeToggle(
            currentMode: currentMode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
