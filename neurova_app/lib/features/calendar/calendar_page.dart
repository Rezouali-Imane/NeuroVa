import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/theme/app_theme.dart' show AppTypography;
import '../../shared/widgets/profile_view_shell.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nc = Theme.of(context).extension<NeuropaColors>()!;
    return Scaffold(
      backgroundColor: nc.background,
      body: ProfileViewShell(
        child: Center(
          child: Text(
            'Calendar',
            style: AppTypography.title1.copyWith(color: nc.textPrimary),
          ),
        ),
      ),
    );
  }
}
