import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../auth/state/auth_notifier.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/theme/app_theme.dart' show AppTypography;
import '../gamification/state/gamification_notifier.dart';
import '../tasks/state/tasks_notifier.dart';
import '../focus/stats/focus_session_notifier.dart';
import '../notes/state/note_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.isVerified = false});

  final bool isVerified;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

enum _ProfileTab { stats, achievements, leaderboard }

class _ProfilePageState extends ConsumerState<ProfilePage> {
  _ProfileTab _selectedTab = _ProfileTab.stats;
  int _selectedNavIndex = 4; // Profile is at index 4
  bool notificationsEnabled = true;
  bool hapticEnabled = true;
  bool focusRemindersEnabled = true;
  bool faithModeEnabled = false;
  String _displayName = 'Loading...';
  String _displayEmail = 'Fetching account details';

  NeuropaColors get _nc => Theme.of(context).extension<NeuropaColors>()!;

  @override
  void initState() {
    super.initState();
    _loadProfileFromBackend();
    Future.microtask(() {
      ref.read(gamificationNotifierProvider.notifier).fetchAll('global');
      ref.read(sessionHistoryProvider.notifier).fetchSessions();
      ref.read(notesNotifierProvider.notifier).fetchNotes();
    });
  }

  Future<void> _loadProfileFromBackend() async {
    final auth = ref.read(authNotifierProvider);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<dynamic>(
        '/api/auth/me',
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );

      if (!mounted) return;

      final data = response.data;
      if (data is! Map<String, dynamic>) return;

      final userData = data['user'];
      if (userData is! Map<String, dynamic>) return;

      final first = (userData['name'] ?? '').toString().trim();
      final last = (userData['lastname'] ?? '').toString().trim();
      final username = (userData['username'] ?? '').toString().trim();
      final email = (userData['email'] ?? '').toString().trim();

      final fullName = '$first $last'.trim();

      setState(() {
        _displayName = fullName.isNotEmpty
            ? fullName
            : (username.isNotEmpty ? username : _displayName);
        _displayEmail = email.isNotEmpty ? email : _displayEmail;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_displayName == 'Loading...') {
          _displayName = 'Your Profile';
        }
        if (_displayEmail == 'Fetching account details') {
          _displayEmail = 'Signed in';
        }
      });
    }
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _nc.background,
      body: Stack(
        children: [
          Positioned(
            left: -80,
            top: -128,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 320,
                height: 320,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x35A2ADD0), Color(0x1FB284BE), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 380,
            child: Opacity(
              opacity: 0.07,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x28F8B878), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              children: [
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildSegmentControl(),
                const SizedBox(height: 20),
                _buildTabBody(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: UnifiedBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProfileCard() {
    final gamif = ref.watch(gamificationNotifierProvider);
    final streak = gamif.streak;
    final totalXp = gamif.totalXp;
    final level = (totalXp / 500).floor() + 1;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [_nc.lilacSurface.withValues(alpha: 0.35), _nc.lilacSurface.withValues(alpha: 0.25), _nc.amethystSurface.withValues(alpha: 0.2)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _nc.textPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _nc.textPrimary.withValues(alpha: 0.25), width: 1.4),
                  ),
                  child: Text(
                    _initialsFromName(_displayName),
                    style: AppTypography.headline3.copyWith(
                      color: _nc.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headline2.copyWith(
                          color: _nc.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _displayEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: _nc.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(text: '✨ Level $level · Pro'),
                          _Pill(text: '🔥 $streak-day streak', opacity: 0.18),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _nc.surfaceElevated.withValues(alpha: 0.6),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '⚡ Level $level → Level ${level + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: _nc.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                                          '${totalXp % 500}/500 XP',
                          style: AppTypography.caption.copyWith(
                            color: _nc.caramelSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (totalXp % 500) / 500,
                      minHeight: 10,
                      backgroundColor: _nc.textPrimary.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(_nc.lilacSurface),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentControl() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _nc.surfaceElevated),
      ),
      child: Row(
        children: [
          _segmentButton('Stats', _ProfileTab.stats),
          _segmentButton('Achievements', _ProfileTab.achievements),
          _segmentButton('Leaderboard', _ProfileTab.leaderboard),
        ],
      ),
    );
  }

  Widget _segmentButton(String label, _ProfileTab tab) {
    final selected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: selected
                ? LinearGradient(
                    colors: [_nc.lilacSurface.withValues(alpha: 0.15), _nc.amethystSurface.withValues(alpha: 0.08)],
                  )
                : null,
            border: Border.all(
              color: selected ? _nc.lilacSurface.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body2.copyWith(
              color: selected ? _nc.lilacSurface : _nc.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    final gamif = ref.watch(gamificationNotifierProvider);
    final streak = gamif.streak;
    final totalXp = gamif.totalXp;
    final level = (totalXp / 500).floor() + 1;
    switch (_selectedTab) {
      case _ProfileTab.stats:
        return Column(
          children: [
            _buildStatsGrid(streak: streak, totalXp: totalXp, level: level),
            const SizedBox(height: 20),
            _buildSectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            _buildToggleCard(),
            const SizedBox(height: 14),
            _buildSectionLabel('CUSTOMIZATION'),
            const SizedBox(height: 8),
            _buildMenuCard(const [
              _MenuData(Icons.palette_outlined, 'Appearance', 'Themes & colors'),
              _MenuData(Icons.language_outlined, 'Language', 'English (US)'),
              _MenuData(Icons.shield_outlined, 'Privacy', 'Data & permissions'),
            ]),
            const SizedBox(height: 14),
            _buildSectionLabel('SUPPORT'),
            const SizedBox(height: 8),
            _buildMenuCard(const [
              _MenuData(Icons.help_outline, 'Help & FAQ', 'Get support'),
              _MenuData(Icons.workspace_premium_outlined, 'Achievements', 'View all badges'),
            ]),
            const SizedBox(height: 14),
                _buildSettingsButton(),
                const SizedBox(height: 10),
                _buildSignOutButton(),
            const SizedBox(height: 14),
          ],
        );
      case _ProfileTab.achievements:
        return _buildAchievementsGrid();
      case _ProfileTab.leaderboard:
        return _buildLeaderboardView();
    }
  }

  Widget _buildStatsGrid({required int streak, required int totalXp, required int level}) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final sessionState = ref.watch(sessionHistoryProvider);
    final noteState = ref.watch(notesNotifierProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.timer_outlined,
                value: '${sessionState.weekMinutes ~/ 60}h',
                label: 'Focus Hrs',
                valueColor: Color(0xFFB284BE),
                gradientA: Color(0x28B284BE),
                gradientB: Color(0x14A2ADD0),
                borderColor: Color(0x28B284BE),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.track_changes,
                value: '${tasksState.tasks.length}',
                label: 'Tasks',
                valueColor: Color(0xFFF8B878),
                gradientA: Color(0x24F8B878),
                gradientB: Color(0x11ECEBBD),
                borderColor: Color(0x28F8B878),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.menu_book_outlined,
                value: '${noteState.notes.length}',
                label: 'Notes',
                valueColor: Color(0xFFA2ADD0),
                gradientA: Color(0x24A2ADD0),
                gradientB: Color(0x11C8A2C8),
                borderColor: Color(0x28A2ADD0),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.flash_on_outlined,
                value: '$totalXp',
                label: 'XP',
                valueColor: Color(0xFFF8B878),
                gradientA: Color(0x21F8B878),
                gradientB: Color(0x10ECEBBD),
                borderColor: Color(0x28F8B878),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid() {
    return Column(
      children: [
        _cardShell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '4/6 Unlocked',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2 achievements remaining',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _BadgeTile(
                emoji: '🎯',
                title: 'First Focus',
                subtitle: 'Completed your first session',
                xp: '+50 XP',
                locked: false,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _BadgeTile(
                emoji: '🔥',
                title: 'Week Warrior',
                subtitle: '7-day streak maintained',
                xp: '+100 XP',
                locked: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _BadgeTile(
                emoji: '📝',
                title: 'Note Taker',
                subtitle: 'Create 50 notes',
                xp: '🔒 75 XP',
                locked: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _BadgeTile(
                emoji: '⚡',
                title: 'Deep Worker',
                subtitle: 'Focus 4 hours in one day',
                xp: '+80 XP',
                locked: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _BadgeTile(
                emoji: '✅',
                title: 'Task Master',
                subtitle: 'Complete 100 tasks',
                xp: '+150 XP',
                locked: false,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _BadgeTile(
                emoji: '🏆',
                title: 'Study Champion',
                subtitle: 'Use all 3 timer modes',
                xp: '🔒 200 XP',
                locked: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardView() {
    return Column(
      children: [
        _buildPodium(),
        const SizedBox(height: 14),
        _leaderboardRow(
          rank: 1,
          initials: 'PM',
          name: 'Priya M.',
          streak: '21 day streak',
          xp: '3,420',
          accent: const Color(0xFFF8B878),
          highlighted: false,
        ),
        const SizedBox(height: 8),
        _leaderboardRow(
          rank: 2,
          initials: 'JL',
          name: 'James L.',
          streak: '14 day streak',
          xp: '2,890',
          accent: const Color(0xFFA2ADD0),
          highlighted: false,
        ),
        const SizedBox(height: 8),
        _leaderboardRow(
          rank: 3,
          initials: _initialsFromName(_displayName),
          name: _displayName,
          streak: '7 day streak',
          xp: '1,340',
          accent: const Color(0xFFB284BE),
          highlighted: true,
          isYou: true,
        ),
        const SizedBox(height: 8),
        _leaderboardRow(
          rank: 4,
          initials: 'CW',
          name: 'Chen W.',
          streak: '5 day streak',
          xp: '1,120',
          accent: const Color(0xFFC8A2C8),
          highlighted: false,
        ),
        const SizedBox(height: 8),
        _leaderboardRow(
          rank: 5,
          initials: 'NR',
          name: 'Nina R.',
          streak: '3 day streak',
          xp: '980',
          accent: const Color(0xFFECEBBD),
          highlighted: false,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Syne',
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildToggleCard() {
    return _cardShell(
      child: Column(
        children: [
          _toggleRow(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Focus reminders & alerts',
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          _dividerInset(),
          _toggleRow(
            icon: Icons.vibration_outlined,
            title: 'Haptic Feedback',
            subtitle: 'Vibrations on actions',
            value: hapticEnabled,
            onChanged: (v) => setState(() => hapticEnabled = v),
          ),
          _dividerInset(),
          _toggleRow(
            icon: Icons.timer_outlined,
            title: 'Focus Reminders',
            subtitle: 'Daily study reminders',
            value: focusRemindersEnabled,
            onChanged: (v) => setState(() => focusRemindersEnabled = v),
          ),
          _dividerInset(),
          _toggleRow(
            icon: Icons.star_outline,
            title: 'Faith Mode',
            subtitle: 'Include prayer blocks in plans',
            value: faithModeEnabled,
            onChanged: (v) => setState(() => faithModeEnabled = v),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuData> items) {
    return _cardShell(
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _menuRow(items[i]),
            if (i < items.length - 1) _dividerInset(),
          ],
        ],
      ),
    );
  }

  Widget _dividerInset() {
    return Container(
      margin: const EdgeInsets.only(left: 52),
      height: 1,
      color: const Color(0xFF2A2440),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _leadingIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white.withValues(alpha: 0.32),
                    fontSize: 11,
                  ),
                ),
              ],
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
                color: value ? const Color(0xFFB284BE) : Colors.white10,
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(_MenuData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _leadingIcon(item.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white.withValues(alpha: 0.32),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
    );
  }

  Widget _leadingIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white54, size: 16),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _handleSignOut,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0x19F5576C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x38F5576C)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFF5576C)),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Syne',
                color: Color(0xFFF5576C),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/settings'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0x141A6EFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x38457AF5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Color(0xFF8AA8FF)),
            SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Syne',
                color: Color(0xFF8AA8FF),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sign Out', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: 'Syne', fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(false),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2440)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'Syne', fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(true),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0x19F5576C),
                          border: Border.all(color: const Color(0x66F5576C)),
                        ),
                        child: const Text('Sign Out', style: TextStyle(color: Color(0xFFF5576C), fontFamily: 'Syne', fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Widget _buildPodium() {
    return _cardShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: _PodiumEntry(
                medal: '🥈',
                initials: 'JL',
                name: 'James',
                xp: '2890',
                height: 78,
                accent: Color(0xFFA2ADD0),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _PodiumEntry(
                medal: '🥇',
                initials: 'PM',
                name: 'Priya',
                xp: '3420',
                height: 108,
                accent: Color(0xFFF8B878),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PodiumEntry(
                medal: '🥉',
                initials: _initialsFromName(_displayName),
                name: _displayName,
                xp: '1340',
                height: 54,
                accent: Color(0xFFB284BE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaderboardRow({
    required int rank,
    required String initials,
    required String name,
    required String streak,
    required String xp,
    required Color accent,
    required bool highlighted,
    bool isYou = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlighted ? const Color(0x44B284BE) : const Color(0xFF2A2440)),
        gradient: highlighted
            ? const LinearGradient(
                colors: [Color(0x21B284BE), Color(0x10A2ADD0)],
              )
            : null,
        color: highlighted ? null : const Color(0xFF1A1628),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      color: Colors.white.withValues(alpha: 0.42),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            color: highlighted ? accent : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isYou)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'YOU',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '🔥 $streak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      color: Colors.white.withValues(alpha: 0.32),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  xp,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: highlighted ? accent : Colors.white.withValues(alpha: 0.70),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'XP',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    color: Colors.white.withValues(alpha: 0.28),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.opacity = 0.22});

  final String text;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Syne',
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.gradientA,
    required this.gradientB,
    required this.borderColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color valueColor;
  final Color gradientA;
  final Color gradientB;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(colors: [gradientA, gradientB]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: valueColor, size: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Syne',
              color: valueColor,
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Syne',
              color: Colors.white.withValues(alpha: 0.40),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.locked,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String xp;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: locked
            ? null
            : const LinearGradient(
                colors: [Color(0x21B284BE), Color(0x10A2ADD0)],
              ),
        color: locked ? Colors.white.withValues(alpha: 0.02) : null,
        border: Border.all(color: locked ? const Color(0xFF2A2440) : const Color(0x30B284BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Syne',
              color: locked ? Colors.white.withValues(alpha: 0.30) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Syne',
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: locked ? Colors.white.withValues(alpha: 0.06) : const Color(0x1FF8B878),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              xp,
              style: TextStyle(
                fontFamily: 'Syne',
                color: locked ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF8B878),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumEntry extends StatelessWidget {
  const _PodiumEntry({
    required this.medal,
    required this.initials,
    required this.name,
    required this.xp,
    required this.height,
    required this.accent,
  });

  final String medal;
  final String initials;
  final String name;
  final String xp;
  final double height;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.3),
          ),
          child: Text(
            initials,
            style: TextStyle(
              fontFamily: 'Syne',
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Syne',
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: 0.30), accent.withValues(alpha: 0.10)],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              xp,
              style: TextStyle(
                fontFamily: 'Syne',
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuData {
  const _MenuData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}
