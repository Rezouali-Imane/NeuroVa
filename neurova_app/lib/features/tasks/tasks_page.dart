import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurova_app/features/auth/state/auth_notifier.dart';
import 'package:neurova_app/features/discipline/models/prayer_schedule_block.dart';
import 'package:neurova_app/features/discipline/state/faith_mode_provider.dart';
import 'package:neurova_app/features/gamification/state/gamification_notifier.dart';
import 'package:neurova_app/shared/theme/app_theme.dart';
import 'package:neurova_app/shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import 'state/tasks_notifier.dart';
import 'models/task_model.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _MiniSpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white54;

    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(4), 0, pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, required this.backgroundColor, this.strokeWidth = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(colors: [color.withValues(alpha: 1.0), color.withValues(alpha: 0.8)]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * (progress.clamp(0.0, 1.0)),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TasksPageState extends ConsumerState<TasksPage> {
  int selectedIndex = 1;
  int selectedTab = 0;
  String selectedPriority = "1";
  String selectedCategory = "OTHER";
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Private UI state (underscored names are used throughout the file).
  String _activeView = 'tasks';
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleMonth = DateTime.now();
  String _calendarScope = 'Month View';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  // Additional controllers used by the sheet
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Aliases so existing code can use underscored names without changing UI code.
  TextEditingController get _searchController => searchController;
  TextEditingController get _titleController => taskController;
  int get _selectedTab => selectedTab;
  set _selectedTab(int v) => selectedTab = v;
  int get _selectedNavIndex => selectedIndex;
  set _selectedNavIndex(int v) => selectedIndex = v;
  String get _selectedPriority => selectedPriority;
  set _selectedPriority(String v) => selectedPriority = v;
  String get _selectedCategory => selectedCategory;
  set _selectedCategory(String v) => selectedCategory = v;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
      ref.read(gamificationNotifierProvider.notifier).fetchAll('global');
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    searchController.dispose();
    _projectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final totalXp = ref.watch(gamificationNotifierProvider).totalXp;
    final faithModeState = ref.watch(faithModeSettingsProvider);
    final prayerBlocks = buildPrayerScheduleBlocks(
      faithModeState.enabled ? faithModeState.prayerTimes : null,
      referenceDate: DateTime.now(),
    );

    List<Task> filteredTasks = tasksState.tasks;
    if (selectedTab == 1) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'PENDING').toList();
    } else if (selectedTab == 2) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'IN_PROGRESS').toList();
    } else if (selectedTab == 3) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'COMPLETED').toList();
    }

    int totalTasks = tasksState.tasks.length;
    int completedTasks = tasksState.tasks.where((t) => t.status == 'COMPLETED').length;
    int inProgress = tasksState.tasks.where((t) => t.status == 'IN_PROGRESS').length;
    int pending = tasksState.tasks.where((t) => t.status == 'PENDING').length;
    double progressPercent = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    // Local aliases expected by the UI code below
    final allTasks = tasksState.tasks;
    final state = tasksState;
    final int todoCount = pending;
    final int inProgressCount = inProgress;
    final int doneCount = completedTasks;
    final visibleTasks = _applyFilters(filteredTasks, _searchController.text.trim().toLowerCase());
    final int progressPercentInt = progressPercent.round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ProfileViewShell(
        child: Stack(
          children: [
            // Ambient glow effects
            Positioned(
              left: -140,
              top: -120,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.purple.withValues(alpha: 0.08), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -110,
              top: 320,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.periwinkle.withValues(alpha: 0.07), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                children: [
                  _buildHeader(allTasks, totalXp),
                  const SizedBox(height: 16),
                  if (_activeView == 'tasks') ...[
                    _buildProgressCard(progressPercentInt, todoCount, inProgressCount, doneCount),
                    const SizedBox(height: 16),
                    if (prayerBlocks.isNotEmpty) ...[
                      _buildPrayerBlocksSection(prayerBlocks),
                      const SizedBox(height: 14),
                    ],
                    _buildSearch(),
                    const SizedBox(height: 14),
                    _buildFilters(),
                    const SizedBox(height: 14),
                  ] else ...[
                    _buildCalendarView(allTasks),
                    const SizedBox(height: 12),
                  ],
                  if (state.isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CustomPaint(
                                painter: _MiniSpinnerPainter(),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Loading tasks...',
                              style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state.error != null)
                    _buildError(state.error!)
                  else if (_activeView == 'tasks')
                    if (visibleTasks.isEmpty)
                      _buildEmptyAllState()
                    else
                      ...visibleTasks.map(_buildTaskCard),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UnifiedBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }

  Widget _buildHeader(List<Task> allTasks, int totalXp) {
    final int doneCount = allTasks.where((t) => t.status == 'COMPLETED').length;
    final int totalCount = allTasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$doneCount of $totalCount done · ⚡ $totalXp XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openCreateSheet,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFC9A5D8), Color(0xFF9FB0D8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB284BE).withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 24, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'My Tasks',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Syne',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 236,
            child: _buildViewTabs(width: 236),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(List<Task> tasks) {
    final selectedDayTasks = _applyFilters(_tasksForDay(_selectedDate, tasks), _searchController.text.trim().toLowerCase());
    final faithModeState = ref.watch(faithModeSettingsProvider);
    final prayerBlocks = buildPrayerScheduleBlocks(
      faithModeState.enabled ? faithModeState.prayerTimes : null,
      referenceDate: _selectedDate,
    );
    final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    final days = List.generate(7, (index) {
      return DateTime(weekStart.year, weekStart.month, weekStart.day + index);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.1,
                    height: 1,
                  ),
                ),
              ),
            ),
            _monthNavButton(Icons.chevron_left, () {
              setState(() {
                final nextVisibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
                final maxDay = DateTime(nextVisibleMonth.year, nextVisibleMonth.month + 1, 0).day;
                _visibleMonth = nextVisibleMonth;
                _selectedDate = DateTime(nextVisibleMonth.year, nextVisibleMonth.month, _selectedDate.day.clamp(1, maxDay));
              });
            }),
            const SizedBox(width: 8),
            _monthNavButton(Icons.chevron_right, () {
              setState(() {
                final nextVisibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
                final maxDay = DateTime(nextVisibleMonth.year, nextVisibleMonth.month + 1, 0).day;
                _visibleMonth = nextVisibleMonth;
                _selectedDate = DateTime(nextVisibleMonth.year, nextVisibleMonth.month, _selectedDate.day.clamp(1, maxDay));
              });
            }),
            const SizedBox(width: 12),
            Builder(
              builder: (anchorContext) {
                return GestureDetector(
                  onTap: () => _openCalendarScopeMenu(anchorContext),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 15, color: Color(0xFFB284BE)),
                        const SizedBox(width: 8),
                        Text(
                          _calendarScope.replaceAll(' View', ''),
                          style: const TextStyle(
                            color: Color(0xFFC59ACE),
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white70),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_calendarScope == 'Month View') ...[
          _buildCalendarDayStrip(days, compact: false),
          const SizedBox(height: 14),
          _buildMonthGrid(tasks),
          const SizedBox(height: 18),
        ] else if (_calendarScope == 'Day View') ...[
          _buildCalendarDayStrip([_selectedDate], compact: true),
          const SizedBox(height: 18),
        ] else ...[
          _buildCalendarDayStrip(days, compact: false),
          const SizedBox(height: 18),
        ],
        Text(
          '${_weekdayName(_selectedDate.weekday)}, ${_monthName(_selectedDate.month)} ${_selectedDate.day}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.74),
            fontFamily: 'Syne',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (prayerBlocks.isNotEmpty) ...[
          _buildPrayerBlocksSection(prayerBlocks),
          const SizedBox(height: 14),
        ],
        if (_calendarScope == 'Day View')
          _buildDayTimeline(selectedDayTasks)
        else if (selectedDayTasks.isEmpty)
          _buildEmptyDayState(compact: _calendarScope == 'Month View')
        else
          ...selectedDayTasks.map(_buildCalendarTaskCard),
      ],
    );
  }

  Widget _buildCalendarDayStrip(List<DateTime> days, {required bool compact}) {
    return SizedBox(
      height: compact ? 82 : 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = _sameDay(day, _selectedDate);
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              width: compact ? 72 : 68,
              decoration: BoxDecoration(
                color: selected ? const Color(0x304A365C) : const Color(0xFF14101F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? const Color(0xFF9B7CB5) : const Color(0xFF2A2440),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['S', 'M', 'T', 'W', 'T', 'F', 'S'][day.weekday % 7],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: selected ? const Color(0xFFDEB8E8) : Colors.white,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 32 - (compact ? 10 : 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthGrid(List<Task> tasks) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = firstOfMonth.weekday % 7;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _monthWeekdayLabel('S'),
              _monthWeekdayLabel('M'),
              _monthWeekdayLabel('T'),
              _monthWeekdayLabel('W'),
              _monthWeekdayLabel('T'),
              _monthWeekdayLabel('F'),
              _monthWeekdayLabel('S'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.88,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayNum = index - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
              final selected = _sameDay(date, _selectedDate);
              final dotCount = _tasksForDay(date, tasks).take(2).length;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x304A365C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: const Color(0xFF9B7CB5)) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          color: selected ? const Color(0xFFDEB8E8) : Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'Syne',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (dotCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(dotCount, (i) {
                            const colors = [Color(0xFFF4B968), Color(0xFFDEB8E8)];
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayTimeline(List<Task> selectedDayTasks) {
    if (selectedDayTasks.isNotEmpty) {
      return Column(children: selectedDayTasks.map(_buildCalendarTaskCard).toList());
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: Column(
        children: List.generate(6, (index) {
          final hour = index;
          final label = '${hour == 0 ? 12 : hour}:00AM';
          return Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: index == 5 ? 0 : 0.06),
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.33),
                fontFamily: 'Syne',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _monthWeekdayLabel(String value) {
    return Text(
      value,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.32),
        fontFamily: 'Syne',
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }

  Future<void> _openCalendarScopeMenu(BuildContext anchorContext) async {
    final box = anchorContext.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF18152A),
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2A2440)),
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.white.withValues(alpha: 0.72)),
              const SizedBox(width: 10),
              const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 10),
        _scopeMenuItem('Day View'),
        _scopeMenuItem('Week View'),
        _scopeMenuItem('Month View'),
      ],
    );

    if (selected != null && mounted) {
      setState(() => _calendarScope = selected);
    }
  }

  PopupMenuItem<String> _scopeMenuItem(String scope) {
    final selected = _calendarScope == scope;
    return PopupMenuItem<String>(
      value: scope,
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              scope,
              style: TextStyle(
                color: selected ? const Color(0xFFC59ACE) : Colors.white.withValues(alpha: 0.8),
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.circle, size: 8, color: Color(0xFFC59ACE)),
        ],
      ),
    );
  }

  Widget _buildViewTabs({double? width}) {
    return Container(
      width: width ?? 320,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF14101F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2440), width: 1),
      ),
      child: Row(
        children: [
          _viewTab('tasks', 'Tasks', Icons.view_list_outlined),
          const SizedBox(width: 4),
          _viewTab('calendar', 'Calendar', Icons.calendar_month_outlined),
        ],
      ),
    );
  }

  Widget _viewTab(String id, String label, IconData icon) {
    final selected = _activeView == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeView = id),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? const Color(0x3A5A3B6D) : Colors.transparent,
            border: Border.all(
              color: selected ? const Color(0xFF8B6BA0) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? const Color(0xFFBE9FCC) : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFFC8A8D2) : Colors.white.withValues(alpha: 0.45),
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(int progressPercent, int todo, int inProgress, int done) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2A2440), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(80, 80),
                  painter: _RingPainter(
                    progress: progressPercent / 100,
                    color: const Color(0xFFB284BE),
                    backgroundColor: const Color(0xFF2A2440),
                    strokeWidth: 7,
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    color: Color(0xFFB284BE),
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _progressStat('$todo', 'To-do', const Color(0xFF7D8BA8)),
                    const SizedBox(width: 18),
                    _progressStat('$inProgress', 'In Progress', const Color(0xFFF8B878)),
                    const SizedBox(width: 18),
                    _progressStat('$done', 'Done', const Color(0xFF4CAF50)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.48),
            fontFamily: 'Syne',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Task> _applyFilters(List<Task> tasks, String q) {
    return tasks.where((task) {
      if (_selectedTab == 1 && !(task.status == 'PENDING' || task.status == 'OVERDUE')) {
        return false;
      }
      if (_selectedTab == 2 && task.status != 'IN_PROGRESS') {
        return false;
      }
      if (_selectedTab == 3 && task.status != 'COMPLETED') {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return task.title.toLowerCase().contains(q) ||
          (task.description ?? '').toLowerCase().contains(q) ||
          task.category.toLowerCase().contains(q);
    }).toList();
  }

  Widget _monthNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF14101F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2440), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2440), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              cursorColor: const Color(0xFFB284BE),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Syne',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search tasks...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontFamily: 'Syne',
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: Icon(Icons.close, size: 18, color: Colors.white.withValues(alpha: 0.4)),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final state = ref.watch(tasksNotifierProvider);
    final tasks = state.tasks;
    final tabs = ['All', 'To-do', 'In\nProgress', 'Done'];
    final counts = <int>[
      tasks.length,
      tasks.where((t) => t.status == 'PENDING' || t.status == 'OVERDUE').length,
      tasks.where((t) => t.status == 'IN_PROGRESS').length,
      tasks.where((t) => t.status == 'COMPLETED').length,
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final selected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0x2E6B5A87) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? const Color(0xFF8B6BA0) : const Color(0xFF3A3850),
                  width: 1.2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF9B6BA8).withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? const Color(0xFFD4B8E0) : Colors.white.withValues(alpha: 0.48),
                      fontFamily: 'Syne',
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF3A3850),
                    ),
                    child: Text(
                      '${counts[index]}',
                      style: TextStyle(
                        color: selected ? const Color(0xFFD4B8E0) : Colors.white.withValues(alpha: 0.42),
                        fontFamily: 'Syne',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemCount: tabs.length,
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x33F5576C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x66F5576C)),
      ),
      child: Text(
        error,
        style: const TextStyle(color: Color(0xFFF5576C), fontFamily: 'Syne'),
      ),
    );
  }

  Widget _buildEmptyDayState({bool compact = false}) {
    return Container(
      margin: EdgeInsets.only(top: compact ? 4 : 16),
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_outlined, color: Colors.white24, size: 30),
          SizedBox(height: 10),
          Text(
            'No tasks for this day',
            style: TextStyle(color: Colors.white54, fontFamily: 'Syne'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerBlocksSection(List<PrayerScheduleBlock> prayerBlocks) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2440), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.more_time, size: 18, color: Color(0xFFB284BE)),
              const SizedBox(width: 8),
              const Text(
                'Protected Prayer Blocks',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${prayerBlocks.length} blocks',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontFamily: 'Syne',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prayerBlocks.map(
            (block) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14101F),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2A2440)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB284BE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Protected time block',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontFamily: 'Syne',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    block.timeLabel,
                    style: const TextStyle(
                      color: Color(0xFFDEB8E8),
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAllState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white24, size: 30),
          SizedBox(height: 10),
          Text(
            'No tasks found',
            style: TextStyle(color: Colors.white54, fontFamily: 'Syne'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final statusInfo = _statusConfig(task.status);

    return GestureDetector(
      onTap: () => _openTaskActionsSheet(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF2A2440),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: statusInfo.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${task.category} · ${_priorityLabel(task.priority)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontFamily: 'Syne',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final nextStatus = _nextStatus(task.status);
                    ref.read(tasksNotifierProvider.notifier).updateTaskStatus(task.taskid, nextStatus);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.status == 'COMPLETED' ? const Color(0x1A4CAF50) : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: task.status == 'COMPLETED' ? const Color(0xFF4CAF50) : const Color(0xFF3A3850),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      task.status == 'COMPLETED' ? Icons.check : Icons.circle_outlined,
                      color: task.status == 'COMPLETED' ? const Color(0xFF4CAF50) : Colors.white.withValues(alpha: 0.25),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: task.status == 'COMPLETED' ? Colors.white.withValues(alpha: 0.48) : Colors.white,
                fontFamily: 'Syne',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.2,
                decoration: task.status == 'COMPLETED' ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(width: 6),
                Text(
                  _deadlineLabel(task.deadline),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontFamily: 'Syne',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: statusInfo.color.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.color,
                      fontFamily: 'Syne',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    )
    );
  }

  Widget _buildCalendarTaskCard(Task task) {
    final statusInfo = _statusConfig(task.status);
    final deadline = task.deadline;
    final timeLabel = _timeRangeLabel(deadline);

    return GestureDetector(
      onTap: () => _openTaskActionsSheet(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF2A2440), width: 1),
          boxShadow: [
            BoxShadow(
              color: statusInfo.color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 120,
              decoration: BoxDecoration(
                color: statusInfo.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Syne',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.48),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontFamily: 'Syne',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.38),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.description?.trim().isNotEmpty == true ? task.description!.trim() : task.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.42),
                              fontFamily: 'Syne',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeRangeLabel(DateTime? dt) {
    if (dt == null) return 'No time set';
    final end = dt.add(const Duration(hours: 1));

    String format(DateTime t) {
      final hour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
      final suffix = t.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${t.minute.toString().padLeft(2, '0')} $suffix';
    }

    return '${format(dt)} - ${format(end)}';
  }

  

  _TaskStatusConfig _statusConfig(String status) {
    switch (status) {
      case 'COMPLETED':
        return const _TaskStatusConfig(label: 'Done', color: AppColors.success);
      case 'IN_PROGRESS':
        return const _TaskStatusConfig(label: 'In Progress', color: AppColors.amber);
      default:
        return const _TaskStatusConfig(label: 'To-do', color: AppColors.purple);
    }
  }

  String _nextStatus(String current) {
    if (current == 'PENDING' || current == 'OVERDUE') return 'IN_PROGRESS';
    if (current == 'IN_PROGRESS') return 'COMPLETED';
    return 'PENDING';
  }

  String _priorityLabel(int p) {
    if (p >= 3) return 'High';
    if (p >= 1) return 'Medium';
    return 'Low';
  }

  String _deadlineLabel(DateTime? dt) {
    if (dt == null) return 'No deadline';
    return '${_monthName(dt.month).substring(0, 3)} ${dt.day}';
  }

  List<Task> _tasksForDay(DateTime date, List<Task> tasks) {
    return tasks.where((task) {
      final deadline = task.deadline;
      if (deadline == null) {
        return false;
      }
      return _sameDay(deadline, date);
    }).toList()
      ..sort((a, b) {
        final aDeadline = a.deadline;
        final bDeadline = b.deadline;
        if (aDeadline == null && bDeadline == null) return 0;
        if (aDeadline == null) return 1;
        if (bDeadline == null) return -1;
        return aDeadline.compareTo(bDeadline);
      });
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  void _openTaskActionsSheet(Task task) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF181526),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2440)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: Color(0xFFC6A6DC)),
                    title: const Text(
                      'Edit task',
                      style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openCreateSheet(task);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFFFF7A7A)),
                    title: const Text(
                      'Delete task',
                      style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _confirmDeleteTask(task);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181526),
          title: const Text('Delete task?', style: TextStyle(color: Colors.white, fontFamily: 'Syne')),
          content: Text(
            'This will permanently remove "${task.title}".',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontFamily: 'Syne'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFFF7A7A))),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(tasksNotifierProvider.notifier).deleteTask(task.taskid);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        backgroundColor: const Color(0xFF1A1628),
      ),
    );
  }

  void _openCreateSheet([Task? task]) {
    _titleController.text = task?.title ?? '';
    _projectController.text = '';
    _descriptionController.text = task?.description ?? '';
    _selectedPriority = (task?.priority ?? 1).toString();
    _selectedCategory = task?.category ?? 'OTHER';
    _selectedTime = task?.deadline != null
        ? TimeOfDay.fromDateTime(task!.deadline!)
        : const TimeOfDay(hour: 12, minute: 0);
    DateTime? selectedDeadline = task?.deadline != null
        ? DateTime(task!.deadline!.year, task.deadline!.month, task.deadline!.day)
        : _selectedDate;
    final isEditing = task != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  height: 760,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF181526),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing ? 'Edit Task' : 'New Task',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(sheetContext),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                                child: const Icon(Icons.close, color: Colors.white70, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'TASK',
                          style: TextStyle(
                            color: Color(0x55FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _sheetInput(_titleController, 'What needs to be done?'),
                        const SizedBox(height: 14),
                        const Text(
                          'PROJECT',
                          style: TextStyle(
                            color: Color(0x55FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _sheetInput(_projectController, 'Project name...'),
                        const SizedBox(height: 14),
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: Color(0x55FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _sheetInput(_descriptionController, 'Add notes or details...', maxLines: 3),
                        const SizedBox(height: 16),
                        const Text(
                          'PRIORITY',
                          style: TextStyle(
                            color: Color(0x55FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _priorityChip('3', 'High', setModalState),
                            const SizedBox(width: 8),
                            _priorityChip('1', 'Medium', setModalState),
                            const SizedBox(width: 8),
                            _priorityChip('0', 'Low', setModalState),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CATEGORY',
                          style: TextStyle(
                            color: Color(0x55FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _categoryChip('ACADEMIC', setModalState, emoji: '📚'),
                            _categoryChip('PERSONAL', setModalState, emoji: '🌱'),
                            _categoryChip('WORK', setModalState, emoji: '💼'),
                            _categoryChip('HEALTH', setModalState, emoji: '🏃'),
                            _categoryChip('OTHER', setModalState, emoji: '📌'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _sheetDateTimeField(
                                label: 'DATE',
                                value: _deadlineDisplayLabel(selectedDeadline),
                                icon: Icons.calendar_today,
                                onTap: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDeadline ?? now,
                                    firstDate: DateTime(now.year - 2),
                                    lastDate: DateTime(now.year + 5),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFFC6A6DC),
                                            onPrimary: Colors.white,
                                            surface: Color(0xFF1E1830),
                                            onSurface: Color(0xFFE7DAF4),
                                          ),
                                          dialogTheme: const DialogThemeData(
                                            backgroundColor: Color(0xFF1A152A),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked == null) return;
                                  setModalState(() {
                                    selectedDeadline = DateTime(picked.year, picked.month, picked.day);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _sheetDateTimeField(
                                label: 'TIME',
                                value: _selectedTime.format(context),
                                icon: Icons.schedule,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFFC6A6DC),
                                            onPrimary: Colors.white,
                                            surface: Color(0xFF1E1830),
                                            onSurface: Color(0xFFE7DAF4),
                                          ),
                                          timePickerTheme: const TimePickerThemeData(
                                            backgroundColor: Color(0xFF1A152A),
                                            hourMinuteTextColor: Color(0xFFEDE2F8),
                                            dialHandColor: Color(0xFFC6A6DC),
                                            dialBackgroundColor: Color(0x332B2140),
                                            entryModeIconColor: Color(0xFFC6A6DC),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked == null) return;
                                  setModalState(() {
                                    _selectedTime = picked;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final title = _titleController.text.trim();
                            if (title.isEmpty) {
                              debugPrint('[Tasks] Please enter a task title');
                              return;
                            }

                            final deadline = selectedDeadline;
                            final combinedDeadline = deadline == null
                                ? null
                                : DateTime(
                                    deadline.year,
                                    deadline.month,
                                    deadline.day,
                                    _selectedTime.hour,
                                    _selectedTime.minute,
                                  );

                            if (isEditing) {
                              await ref.read(tasksNotifierProvider.notifier).updateTask(
                                    taskId: task.taskid,
                                    title: title,
                                    description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                    deadline: combinedDeadline,
                                    priority: int.tryParse(selectedPriority) ?? 1,
                                    category: selectedCategory,
                                    syncWithGoogle: task.syncwithgoogle,
                                  );
                            } else {
                              final localStorage = ref.read(localStorageServiceProvider);
                              final userId = await localStorage.readUserId();

                              if (!context.mounted) return;

                              if (userId == null) {
                                debugPrint('[Tasks] User not authenticated');
                                return;
                              }

                              await ref.read(tasksNotifierProvider.notifier).createTask(
                                    userId: userId,
                                    title: title,
                                    listId: 'default',
                                    priority: int.tryParse(selectedPriority) ?? 1,
                                    status: 'PENDING',
                                    category: selectedCategory,
                                    description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                    deadline: combinedDeadline,
                                  );
                            }

                            _titleController.clear();
                            _projectController.clear();
                            _descriptionController.clear();
                            selectedPriority = '1';
                            selectedCategory = 'OTHER';

                            if (!context.mounted) return;
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB284BE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                isEditing ? 'Save Changes' : 'Add Task',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14101F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        ),
      ),
    );
  }

  String _deadlineDisplayLabel(DateTime? deadline) {
    if (deadline == null) {
      return 'Pick date';
    }

    return '${deadline.month.toString().padLeft(2, '0')}/${deadline.day.toString().padLeft(2, '0')}/${deadline.year}';
  }

  Widget _sheetDateTimeField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x55FFFFFF),
              fontFamily: 'Syne',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x332B2140),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2440)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFD4B6EA)),
                const SizedBox(width: 10),
                Expanded(child: Text(value, style: const TextStyle(color: Color(0xFFE9DCF8), fontFamily: 'Syne'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String value, String label, void Function(void Function()) setModalState) {
    final selected = _selectedPriority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => _selectedPriority = value),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0x1FF8B878) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? const Color(0x66F8B878) : const Color(0xFF2A2440)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFFF8B878) : Colors.white.withValues(alpha: 0.45),
              fontFamily: 'Syne',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String category, void Function(void Function()) setModalState, {required String emoji}) {
    final selected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setModalState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1FB284BE) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0x66B284BE) : const Color(0xFF2A2440)),
        ),
        child: Text(
          '$emoji  ${_categoryTitle(category)}',
          style: TextStyle(
            color: selected ? const Color(0xFFCEA4D4) : Colors.white.withValues(alpha: 0.45),
            fontFamily: 'Syne',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _categoryTitle(String category) {
    switch (category.toUpperCase()) {
      case 'DESIGN':
        return 'Design';
      case 'DEVELOPMENT':
        return 'Development';
      case 'RESEARCH':
        return 'Research';
      case 'STUDY':
        return 'Study';
      case 'PERSONAL':
        return 'Personal';
      case 'OTHER':
      default:
        final s = category.toLowerCase();
        return s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : category;
    }
  }
}

class _TaskStatusConfig {
  final String label;
  final Color color;
  const _TaskStatusConfig({required this.label, required this.color});
}

class ProgressCirclePainter extends CustomPainter {
  final double progress;
  ProgressCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0x5EE8E8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB284BE), Color(0xFFC8A2C8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
