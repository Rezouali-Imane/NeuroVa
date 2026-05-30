import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/theme/app_theme.dart' show AppTypography;
import '../../shared/widgets/profile_view_shell.dart';
import '../discipline/models/prayer_schedule_block.dart';
import '../discipline/state/faith_mode_provider.dart';
import '../tasks/models/task_model.dart';
import '../tasks/state/tasks_notifier.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _visibleMonth = DateTime.now();

  NeuropaColors get _nc => Theme.of(context).extension<NeuropaColors>() ?? NeuropaColors.light;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final faithModeState = ref.watch(faithModeSettingsProvider);
    final prayerBlocks = buildPrayerScheduleBlocks(
      faithModeState.enabled ? faithModeState.prayerTimes : null,
      referenceDate: _selectedDay,
    );
    final monthDays = _buildMonthDays(_visibleMonth);
    final selectedTasks = _tasksForSelectedDay(tasksState.tasks);

    return Scaffold(
      backgroundColor: _nc.background,
      body: ProfileViewShell(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              Text('Calendar', style: AppTypography.headline1.copyWith(color: _nc.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Tap a day to see its tasks.',
                style: AppTypography.body2.copyWith(color: _nc.textSecondary),
              ),
              const SizedBox(height: 20),
              _buildMonthHeader(),
              const SizedBox(height: 12),
              _buildWeekLabels(),
              const SizedBox(height: 10),
              _buildMonthGrid(monthDays),
              const SizedBox(height: 24),
              if (prayerBlocks.isNotEmpty) ...[
                _buildPrayerBlocksSection(prayerBlocks),
                const SizedBox(height: 18),
              ],
              Text(
                'Tasks for ${_formatSelectedDay(_selectedDay)}',
                style: AppTypography.title1.copyWith(color: _nc.textPrimary),
              ),
              const SizedBox(height: 12),
              if (tasksState.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (selectedTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No tasks for this day',
                    style: AppTypography.body1.copyWith(color: _nc.textMuted),
                  ),
                )
              else
                ...selectedTasks.map(_buildTaskCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
            style: AppTypography.headline2.copyWith(color: _nc.textPrimary),
          ),
        ),
        _navButton(Icons.chevron_left, () {
          setState(() {
            _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
          });
        }),
        const SizedBox(width: 8),
        _navButton(Icons.chevron_right, () {
          setState(() {
            _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
          });
        }),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _nc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _nc.surfaceElevated),
        ),
        child: Icon(icon, color: _nc.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildWeekLabels() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(color: _nc.textMuted, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid(List<DateTime?> days) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        if (day == null) {
          return const SizedBox.shrink();
        }

        final isSelected = _sameDate(day, _selectedDay);
        final isToday = _sameDate(day, DateTime.now());

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _nc.lilacSurface.withValues(alpha: 0.2) : _nc.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _nc.lilacSurface : (isToday ? _nc.amethystSurface : _nc.surfaceElevated),
                width: isSelected ? 1.4 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: AppTypography.body1.copyWith(
                color: isSelected ? _nc.lilacSurface : _nc.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final status = task.status;
    final statusColor = switch (status) {
      'COMPLETED' => Colors.green,
      'IN_PROGRESS' => _nc.amethystSurface,
      'OVERDUE' => Colors.redAccent,
      _ => _nc.lemonSurface,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _nc.surfaceElevated),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body1.copyWith(color: _nc.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: AppTypography.caption.copyWith(color: _nc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerBlocksSection(List<PrayerScheduleBlock> prayerBlocks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _nc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _nc.surfaceElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.more_time_rounded, size: 18, color: _nc.lilacSurface),
              const SizedBox(width: 8),
              Text(
                'Prayer blocks',
                style: AppTypography.title2.copyWith(color: _nc.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prayerBlocks.map(
            (block) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _nc.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _nc.surfaceElevated),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _nc.lilacSurface,
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
                          style: AppTypography.body1.copyWith(
                            color: _nc.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Protected time block',
                          style: AppTypography.caption.copyWith(color: _nc.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    block.timeLabel,
                    style: AppTypography.body1.copyWith(
                      color: _nc.lilacSurface,
                      fontWeight: FontWeight.w700,
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

  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday == DateTime.monday ? 0 : firstDay.weekday - 1;
    final result = <DateTime?>[
      ...List<DateTime?>.filled(leadingBlanks, null),
      ...List<DateTime>.generate(daysInMonth, (index) => DateTime(month.year, month.month, index + 1)),
    ];

    while (result.length % 7 != 0) {
      result.add(null);
    }
    return result;
  }

  List<Task> _tasksForSelectedDay(List<Task> tasks) {
    return tasks.where((task) {
      final deadline = task.deadline;
      if (deadline == null) return false;
      return deadline.year == _selectedDay.year &&
          deadline.month == _selectedDay.month &&
          deadline.day == _selectedDay.day;
    }).toList();
  }

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) => const [
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
      ][month - 1];

  String _formatSelectedDay(DateTime day) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[day.weekday - 1]}, ${_monthName(day.month)} ${day.day}, ${day.year}';
  }
}
