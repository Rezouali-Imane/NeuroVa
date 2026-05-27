import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/index.dart' show NeurThemeToggle;
import '../../shared/theme/app_theme.dart' show AppTypography;

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool notifications = true;
  bool haptic = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    
    // Safely get NeuropaColors from theme
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.light;

    return Scaffold(
      backgroundColor: nc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.headline2.copyWith(color: nc.textPrimary),
        ),
      ),
      body: ProfileViewShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _section('Preferences', nc),
            _card(
              nc: nc,
              child: Column(
                children: [
                  _switchTile('Notifications', notifications, (v) => setState(() => notifications = v), nc),
                  _divider(nc),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style: AppTypography.title2.copyWith(color: nc.textPrimary),
                        ),
                        NeurThemeToggle(
                          currentMode: themeMode,
                          onChanged: (newMode) {
                            ref.read(themeModeProvider.notifier).state = newMode;
                          },
                        ),
                      ],
                    ),
                  ),
                  _divider(nc),
                  _switchTile('Haptic Feedback', haptic, (v) => setState(() => haptic = v), nc),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _section('General', nc),
            _card(
              nc: nc,
              child: Column(
                children: [
                  _menuTile('Language', 'English (US)', nc),
                  _divider(nc),
                  _menuTile('Privacy', 'Data & permissions', nc),
                  _divider(nc),
                  _menuTile('Help & FAQ', 'Get support', nc),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [nc.lilacSurface.withOpacity(0.16), nc.amethystSurface.withOpacity(0.08)],
                  ),
                  border: Border.all(color: nc.lilacSurface.withOpacity(0.24)),
                ),
                child: Text(
                  'Back To Profile',
                  style: AppTypography.title2.copyWith(color: nc.lilacSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, NeuropaColors nc) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Syne',
            color: nc.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _card({required NeuropaColors nc, required Widget child}) => Container(
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: nc.surfaceElevated),
        ),
        child: child,
      );

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged, NeuropaColors nc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.title2.copyWith(color: nc.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: value ? nc.lilacSurface : nc.surfaceElevated,
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nc.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(String title, String subtitle, NeuropaColors nc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title2.copyWith(color: nc.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.body2.copyWith(color: nc.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: nc.textSecondary, size: 18),
        ],
      ),
    );
  }

  Widget _divider(NeuropaColors nc) => Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        height: 1,
        color: nc.surfaceElevated,
      );
}
