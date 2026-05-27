import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
// ignore: unused_import
import '../../shared/theme/app_theme.dart' show AppTypography;

class ProfileViewShell extends StatelessWidget {
  final Widget child;

  const ProfileViewShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.dark;

    return SafeArea(
      child: Container(
        width: double.infinity,
        color: nc.background,
        child: child,
      ),
    );
  }
}
