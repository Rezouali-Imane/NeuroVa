import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/theme/app_theme.dart' as core_theme;
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import '../ai/state/insights_provider.dart';

class Dashboard1 extends ConsumerStatefulWidget {
  const Dashboard1({super.key});

  @override
  ConsumerState<Dashboard1> createState() => _Dashboard1State();
}

class _Dashboard1State extends ConsumerState<Dashboard1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  int _selectedEnergy = 3;
  final int _unreadNotifications = 2;

  // Helper getter for NeuropaColors
  core_theme.NeuropaColors get _nc => Theme.of(context).extension<core_theme.NeuropaColors>()!;

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': 'Task Reminder',
      'message': 'Low-fi Wireframes due in 2 hours',
      'time': '10m ago',
      'isRead': false,
      'icon': Icons.track_changes,
      'color': AppColors.amber,
    },
    {
      'title': 'Daily Challenge',
      'message': 'Complete 3 focus sessions today',
      'time': '2h ago',
      'isRead': false,
      'icon': Icons.emoji_events,
      'color': AppColors.purple,
    },
    {
      'title': 'Session Complete',
      'message': 'Great work! +50 XP earned',
      'time': '3h ago',
      'isRead': true,
      'icon': Icons.schedule,
      'color': AppColors.success,
    },
    {
      'title': 'Study Room Invite',
      'message': 'Sarah invited you to Algorithms',
      'time': '1d ago',
      'isRead': true,
      'icon': Icons.people,
      'color': AppColors.periwinkle,
    },
  ];

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/focus');
        break;
      case 3:
        context.go('/ai');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Load insights when the dashboard is first loaded
    Future.microtask(() {
      try {
        ref.read(insightsProvider.notifier).loadInsights();
      } catch (e) {
        // Silently fail if insights can't be loaded
        print('Failed to load insights: $e');
      }
    });
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showNotificationsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: _nc.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xxxlarge)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _nc.lemonSurface.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                              border: Border.all(color: _nc.lemonSurface.withOpacity(0.3)),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.notifications_none, color: _nc.lemonSurface, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: AppTypography.headline3.copyWith(fontSize: 20),
                              ),
                              Text(
                                '$_unreadNotifications unread',
                                style: AppTypography.caption.copyWith(color: _nc.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _nc.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                            border: Border.all(color: _nc.surfaceElevated.withOpacity(0.5)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.close, color: _nc.textSecondary, size: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return _buildNotificationTile(item);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _nc.background,
      drawer: _buildDrawer(),
      body: ProfileViewShell(
        child: Stack(
          children: [
            // Ambient glow effects
            Positioned(
              left: -140,
              top: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_nc.lilacSurface.withOpacity(0.16), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -120,
              top: 300,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_nc.amethystSurface.withOpacity(0.14), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildHeroBanner(),
                    const SizedBox(height: 20),
                    _buildTopStats(),
                    const SizedBox(height: 24),
                    _buildFeatureGrid(),
                    const SizedBox(height: 32),
                    _buildTasksHeader(),
                    const SizedBox(height: 16),
                    _buildTasksList(),
                    const SizedBox(height: 28),
                    _buildFocusHeatmap(),
                    const SizedBox(height: 20),
                    _buildAIInsight(),
                    const SizedBox(height: 20),
                    _buildDailyChallenges(),
                    const SizedBox(height: 20),
                    _buildWeekWarrior(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 69,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(
                    width: 39.99,
                    height: 39.99,
                    decoration: BoxDecoration(
                      color: _nc.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 0.75, color: _nc.surfaceElevated),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.menu, color: _nc.textPrimary, size: 17),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 43.28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_greeting()} 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _nc.textSecondary.withValues(alpha: 0.38),
                            fontSize: 12,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.12,
                          ),
                        ),
                        Text(
                          'Hello, Alex!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _nc.textPrimary,
                            fontSize: 22,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.65),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _showNotificationsSheet,
                child: SizedBox(
                  width: 39.99,
                  height: 39.99,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 39.99,
                        height: 39.99,
                        decoration: BoxDecoration(
                          color: _nc.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(width: 0.75, color: _nc.surfaceElevated),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.notifications_none, color: _nc.textPrimary, size: 16),
                      ),
                      Positioned(
                        right: -3.38,
                        top: -3.38,
                        child: Container(
                          width: 20.27,
                          height: 20.27,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_nc.lemonSurface, _nc.caramelSurface],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_unreadNotifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _nc.background,
                              fontSize: 9,
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 7.99),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  width: 39.99,
                  height: 39.99,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_nc.lilacSurface, _nc.amethystSurface],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _nc.lilacSurface.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AJ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _nc.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return GestureDetector(
      onTap: () => context.go('/focus'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7748B5), Color(0xFFB79FD0), Color(0xFFB4BEDD)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  'READY TO FOCUS?',
                  style: AppTypography.label.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start a',
                        style: AppTypography.headline1.copyWith(
                          fontSize: 30,
                          height: 1.0,
                          letterSpacing: -0.6,
                        ),
                      ),
                      Text(
                        'Focus',
                        style: AppTypography.headline1.copyWith(
                          fontSize: 30,
                          height: 1.0,
                          letterSpacing: -0.6,
                        ),
                      ),
                      Text(
                        'Session',
                        style: AppTypography.headline1.copyWith(
                          fontSize: 30,
                          height: 1.0,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.26), width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 8),
                  Text(
                    '25:00 Pomodoro',
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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

  Widget _heroBadge(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          Text(
            value,
            style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.timer_outlined,
            value: '3h\n20m',
            label: 'Focused Today',
            colors: [const Color(0x28B284BE), const Color(0x10C8A2C8)],
            valueColor: const Color(0xFFB284BE),
            borderColor: const Color(0x30B284BE),
            iconChipColor: const Color(0x21B284BE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_box_outlined,
            value: '1/3',
            label: 'Tasks Done',
            colors: [const Color(0x28A2ADD0), const Color(0x10C8A2C8)],
            valueColor: const Color(0xFFA2ADD0),
            borderColor: const Color(0x30A2ADD0),
            iconChipColor: const Color(0x21A2ADD0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            value: '7 days',
            label: 'Streak',
            colors: [const Color(0x24F8B878), const Color(0x10ECEBBD)],
            valueColor: const Color(0xFFF8B878),
            borderColor: const Color(0x30F8B878),
            iconChipColor: const Color(0x21F8B878),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> colors,
    required Color valueColor,
    required Color borderColor,
    required Color iconChipColor,
  }) {
    return Container(
      height: 127.46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(width: 0.75, color: borderColor),
        gradient: LinearGradient(
          begin: const Alignment(0.15, 0.0),
          end: const Alignment(0.85, 1.0),
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0.75,
            top: 0.75,
            right: 0.75,
            child: Container(
              height: 62.97,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                gradient: LinearGradient(
                  begin: const Alignment(0.5, 0),
                  end: const Alignment(0.5, 1),
                  colors: [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.74, 16.74, 16.74, 16.74),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconChipColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.86)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 17,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          height: 0.98,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 10,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'AI Chat',
                subtitle: 'Ask anything',
                icon: Icons.psychology_outlined,
                colors: [AppColors.purple, const Color(0xFF886392)],
                route: '/ai',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                title: 'Study Room',
                subtitle: 'Study together',
                icon: Icons.people_outline,
                colors: [const Color(0xFFEAA063), const Color(0xFFC7814A)],
                route: '/rooms',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'Discipline',
                subtitle: 'Block distractions',
                icon: Icons.shield_outlined,
                colors: [AppColors.periwinkle, const Color(0xFF7E89AB)],
                route: '/discipline',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                title: 'Notes',
                subtitle: 'Your knowledge base',
                icon: Icons.menu_book_outlined,
                colors: [AppColors.lilac, const Color(0xFF9E7E9E)],
                route: '/notes',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    String? route,
  }) {
    return GestureDetector(
      onTap: route == null ? null : () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxlarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Icon(Icons.arrow_forward_outlined, color: Colors.white.withOpacity(0.5), size: 16),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.title1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Tasks",
              style: AppTypography.headline2,
            ),
            const SizedBox(height: 6),
            Text(
              '33% complete · 1 of 3 done',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 12),
            Container(
              width: 180,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.amber],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/tasks'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  'See all',
                  style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: AppColors.textSecondary, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: [
        _buildTaskItem(
          label: 'Grocery App - 10:00',
          title: 'Market Research',
          status: 'Done',
          colors: [const Color(0xFF1A1628), const Color(0xFF1A1628)],
          textColor: Colors.white,
          tagColor: Colors.white24,
          isDone: true,
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          label: 'Grocery App - 12:00',
          title: 'Competitive Analysis',
          status: 'In Progress',
          colors: [_nc.lilacSurface, _nc.amethystSurface],
          textColor: Colors.white,
          tagColor: _nc.amethystSurface.withOpacity(0.85),
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          label: 'Uber Eats Redesign - 19:00',
          title: 'Low-fi Wireframes',
          status: 'To-do',
          colors: [_nc.lemonSurface, _nc.caramelSurface.withOpacity(0.9)],
          textColor: Colors.black.withOpacity(0.8),
          tagColor: _nc.caramelSurface.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required String label,
    required String title,
    required String status,
    required List<Color> colors,
    required Color textColor,
    required Color tagColor,
    bool isDone = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxlarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: textColor.withOpacity(isDone ? 0.3 : 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTypography.title2.copyWith(
                    color: textColor.withOpacity(isDone ? 0.28 : 1),
                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: AppTypography.caption.copyWith(
                color: textColor.withOpacity(isDone ? 0.38 : 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusHeatmap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxxlarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _nc.surfaceElevated.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus Activity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title1,
                          ),
                          Text(
                            'Past 7 days',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(color: _nc.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+12% this week',
                      style: AppTypography.caption.copyWith(color: Colors.green, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Heatmap Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              Color cellColor = _nc.surfaceElevated;
              if (index % 7 == 4 && index > 10) {
                cellColor = _nc.lilacSurface;
              } else if (index % 3 == 0) {
                cellColor = _nc.surfaceElevated.withOpacity(0.8);
              } else if (index % 5 == 0) {
                cellColor = _nc.surfaceElevated.withOpacity(0.6);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('M', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('T', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('W', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('T', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('F', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('S', style: AppTypography.caption.copyWith(color: Colors.grey)),
              Text('S', style: AppTypography.caption.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Less', style: AppTypography.caption.copyWith(color: _nc.textMuted)),
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _nc.surfaceElevated, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _nc.surfaceElevated.withOpacity(0.6), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _nc.surfaceElevated.withOpacity(0.8), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _nc.amethystSurface.withOpacity(0.85), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _nc.lilacSurface, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('More', style: AppTypography.caption.copyWith(color: _nc.textMuted)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('18h\n40m', style: AppTypography.headline3.copyWith(height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Week Total', style: AppTypography.caption.copyWith(color: _nc.textMuted)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Friday', style: AppTypography.headline3.copyWith(color: _nc.lemonSurface, height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Best Day', style: AppTypography.caption.copyWith(color: _nc.textMuted)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('2h\n40m', style: AppTypography.headline3.copyWith(color: _nc.amethystSurface, height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Daily Avg', style: AppTypography.caption.copyWith(color: _nc.textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight() {
    return Consumer(
      builder: (context, ref, child) {
        final insightsState = ref.watch(insightsProvider);
        final currentInsight = insightsState.currentInsight;

        if (insightsState.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.xxlarge),
              border: Border.all(color: _nc.surfaceElevated.withOpacity(0.5)),
              gradient: LinearGradient(
                colors: [_nc.surface.withOpacity(0.8), _nc.background],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox(
              height: 80,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (insightsState.hasError || currentInsight == null) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              ref.read(insightsProvider.notifier).previousInsight();
            } else if (details.primaryVelocity! < 0) {
              ref.read(insightsProvider.notifier).nextInsight();
            }
          },
          child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.xxlarge),
                border: Border.all(color: _nc.surfaceElevated.withOpacity(0.5)),
                gradient: LinearGradient(
                  colors: [_nc.surface.withOpacity(0.8), _nc.background],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _nc.surfaceElevated.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppBorderRadius.large),
                    ),
                    child: Icon(Icons.psychology_outlined, color: _nc.amethystSurface, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: _nc.amethystSurface, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  currentInsight.title,
                                  style: AppTypography.label.copyWith(color: _nc.amethystSurface),
                                ),
                              ],
                            ),
                            // Animated dot indicators
                            Row(
                              children: List.generate(insightsState.insights.length, (index) {
                                final isActive = index == insightsState.currentInsightIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  margin: const EdgeInsets.only(left: 4),
                                  width: isActive ? 12 : 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? _nc.amethystSurface
                                        : _nc.amethystSurface.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentInsight.content,
                          style: AppTypography.body1.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        );
      },
    );
  }

  Widget _buildWeekWarrior() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxlarge),
        border: Border.all(color: _nc.lemonSurface.withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [_nc.lemonSurface.withOpacity(0.15), _nc.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _nc.lemonSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
            ),
            child: Icon(Icons.star, color: _nc.lemonSurface, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week Warrior 🏆',
                  style: AppTypography.title1,
                ),
                const SizedBox(height: 4),
                Text(
                  '7-day streak — keep it up!',
                  style: AppTypography.body2.copyWith(color: _nc.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+100',
                style: AppTypography.headline3.copyWith(color: _nc.lemonSurface),
              ),
              Text(
                'XP earned',
                style: AppTypography.caption.copyWith(color: _nc.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenges() {
    final List<Map<String, dynamic>> challenges = [
      {
        'title': 'Triple Focus',
        'description': 'Complete 3 Pomodoro sessions',
        'progress': 2,
        'target': 3,
        'xp': 75,
        'completed': false,
        'icon': Icons.track_changes,
        'color': _nc.lilacSurface,
      },
      {
        'title': 'Task Master',
        'description': 'Finish 5 tasks',
        'progress': 4,
        'target': 5,
        'xp': 50,
        'completed': false,
        'icon': Icons.task_alt,
        'color': _nc.amethystSurface,
      },
      {
        'title': 'Note Taker',
        'description': 'Create 2 new notes',
        'progress': 2,
        'target': 2,
        'xp': 30,
        'completed': true,
        'icon': Icons.menu_book,
        'color': _nc.lemonSurface,
      },
      {
        'title': 'Early Bird',
        'description': 'Start session before 9 AM',
        'progress': 1,
        'target': 1,
        'xp': 100,
        'completed': true,
        'icon': Icons.wb_sunny,
        'color': _nc.lemonSurface,
      },
    ];

    final int completed = challenges.where((c) => c['completed'] == true).length;
    final int xp = challenges
        .where((c) => c['completed'] == true)
        .fold<int>(0, (sum, c) => sum + (c['xp'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _nc.lemonSurface.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.calendar_month, color: _nc.lemonSurface, size: 16),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenges',
                      style: AppTypography.headline2,
                    ),
                    Text(
                      '$completed of ${challenges.length} completed',
                      style: AppTypography.caption.copyWith(color: _nc.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _nc.lemonSurface.withOpacity(0.16),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                border: Border.all(color: _nc.lemonSurface.withOpacity(0.3)),
              ),
              child: Text(
                '+$xp XP',
                style: AppTypography.caption.copyWith(
                  color: _nc.lemonSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: challenges.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            final bool isCompleted = challenge['completed'] as bool;
            final int progress = challenge['progress'] as int;
            final int target = challenge['target'] as int;
            final Color color = challenge['color'] as Color;
            final double ratio = target == 0 ? 0 : progress / target;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? color.withOpacity(0.12) : _nc.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.large),
                border: Border.all(
                  color: isCompleted ? color.withOpacity(0.25) : _nc.surfaceElevated.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(challenge['icon'] as IconData, color: color, size: 14),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    challenge['title'] as String,
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge['description'] as String,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progress/$target',
                        style: AppTypography.caption.copyWith(color: _nc.textSecondary.withOpacity(0.7)),
                      ),
                      Text(
                        '+${challenge['xp']} XP',
                        style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: _nc.surfaceElevated.withOpacity(0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return UnifiedBottomNavBar(
      selectedIndex: _currentIndex,
      onNavItemTapped: _onNavTapped,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _nc.background,
      width: 320,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1827), Color(0xFF13111A)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_nc.lilacSurface, _nc.amethystSurface],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.auto_awesome, color: _nc.background, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'NEUROVA',
                            style: AppTypography.title1.copyWith(letterSpacing: -0.5),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _nc.surfaceElevated.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _nc.surfaceElevated.withOpacity(0.5)),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.close, color: Colors.white70, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Profile preview card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
                      gradient: AppGradients.glass(_nc.lilacSurface),
                      border: Border.all(color: _nc.lilacSurface.withOpacity(0.26)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                gradient: AppGradients.purple,
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'AJ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Johnson',
                                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Level 5 · 1,340 XP',
                                        style: AppTypography.caption.copyWith(color: _nc.textSecondary.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: AppColors.amber.withOpacity(0.35)),
                              ),
                              child: Text(
                                '🔥 7',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.amber,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: 0.47,
                            minHeight: 4,
                            backgroundColor: _nc.surfaceElevated.withOpacity(0.4),
                            valueColor: AlwaysStoppedAnimation<Color>(_nc.amethystSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Navigation
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Navigation',
                      style: AppTypography.label.copyWith(color: _nc.textMuted),
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard'),
                    _buildDrawerItem(icon: Icons.check_box_outlined, label: 'Tasks', route: '/tasks'),
                    _buildDrawerItem(icon: Icons.timer_outlined, label: 'Focus', route: '/focus'),
                    _buildDrawerItem(icon: Icons.auto_awesome_outlined, label: 'AI Assistant', route: '/ai'),
                    _buildDrawerItem(icon: Icons.menu_book_outlined, label: 'Notes', route: '/notes'),
                    _buildDrawerItem(icon: Icons.people_outline, label: 'Study Rooms', route: '/rooms'),
                    _buildDrawerItem(icon: Icons.shield_outlined, label: 'Discipline', route: '/discipline'),
                    _buildDrawerItem(icon: Icons.person_outline, label: 'Profile', route: '/profile'),
                    const SizedBox(height: 12),
                    _buildDrawerSnapshotCard(),
                    const SizedBox(height: 10),
                    _buildDrawerEnergyCard(),
                  ],
                ),
              ),
            ),
            // Bottom
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _nc.surfaceElevated.withOpacity(0.5))),
              ),
              child: Column(
                children: [
                  _buildDrawerBottomItem(icon: Icons.notifications_none, label: 'Notifications', onTap: _showNotificationsSheet),
                  _buildDrawerBottomItem(icon: Icons.settings_outlined, label: 'Settings', route: '/settings'),
                  _buildDrawerBottomItem(icon: Icons.help_outline, label: 'Help & FAQ'),
                  const SizedBox(height: 8),
                  ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    tileColor: Colors.red.withOpacity(0.08),
                    leading: const Icon(Icons.logout, color: Colors.red, size: 16),
                    title: Text(
                      'Sign Out',
                      style: AppTypography.body1.copyWith(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                    onTap: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDrawerRouteActive(String route) {
    final String current = GoRouterState.of(context).matchedLocation;
    if (route == '/dashboard') {
      return current == '/dashboard';
    }
    return current.startsWith(route);
  }

  Widget _buildDrawerItem({required IconData icon, required String label, String? route}) {
    final bool isActive = route == null ? false : _isDrawerRouteActive(route);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive ? _nc.lilacSurface.withOpacity(0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: isActive ? _nc.lilacSurface.withOpacity(0.28) : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? _nc.lilacSurface.withOpacity(0.24) : _nc.surfaceElevated.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isActive ? _nc.lilacSurface : _nc.textSecondary.withOpacity(0.7),
          ),
        ),
        title: Text(
          label,
          style: AppTypography.body1.copyWith(
            color: isActive ? _nc.lilacSurface : _nc.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: isActive ? Icon(Icons.chevron_right, color: _nc.lilacSurface, size: 18) : null,
        onTap: () => context.go(route ?? '/dashboard'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.large)),
      ),
    );
  }

  Widget _buildDrawerSnapshotCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: _nc.surfaceElevated.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY\'S SNAPSHOT',
            style: AppTypography.label.copyWith(color: _nc.textMuted, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DrawerStat(label: 'Focused', value: '3h 20m', color: _nc.lilacSurface),
              _DrawerStat(label: 'Tasks', value: '1/3', color: _nc.amethystSurface),
              _DrawerStat(label: 'Streak', value: '7 days', color: _nc.lemonSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerEnergyCard() {
    const List<String> energy = ['😴', '😐', '🙂', '⚡', '🔥'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: _nc.surfaceElevated.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW\'S YOUR ENERGY?',
            style: AppTypography.label.copyWith(color: _nc.textMuted, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(energy.length, (index) {
              final bool active = index == _selectedEnergy;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEnergy = index),
                  child: Container(
                    height: 36,
                    margin: EdgeInsets.only(right: index == energy.length - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: active ? _nc.lemonSurface.withOpacity(0.2) : _nc.surfaceElevated.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? _nc.lemonSurface.withOpacity(0.35) : _nc.surfaceElevated.withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      energy[index],
                      style: TextStyle(fontSize: 18, fontFamily: 'Syne'),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerBottomItem({required IconData icon, required String label, String? route, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: _nc.textSecondary.withOpacity(0.7), size: 16),
      title: Text(
        label,
        style: AppTypography.body1.copyWith(color: _nc.textSecondary.withOpacity(0.85)),
      ),
      onTap: onTap ?? (route != null ? () => context.go(route) : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final bool isRead = item['isRead'] as bool;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? _nc.surface : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: isRead ? _nc.surfaceElevated.withOpacity(0.3) : color.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Icon(item['icon'] as IconData, color: color, size: 15),
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
                        item['title'] as String,
                        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'] as String,
                  style: AppTypography.body2.copyWith(color: _nc.textSecondary.withOpacity(0.7), height: 1.4),
                ),
                const SizedBox(height: 3),
                Text(
                  item['time'] as String,
                  style: AppTypography.caption.copyWith(color: _nc.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DrawerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.body1.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: Theme.of(context).extension<core_theme.NeuropaColors>()!.textMuted),
        ),
      ],
    );
  }
}
