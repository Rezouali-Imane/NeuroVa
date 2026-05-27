import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import '../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import './state/discipline_notifier.dart';
import './state/faith_mode_provider.dart';

class DisciplinePage extends ConsumerStatefulWidget {
  const DisciplinePage({super.key});

  @override
  ConsumerState<DisciplinePage> createState() => _DisciplinePageState();
}

class _DisciplinePageState extends ConsumerState<DisciplinePage> {
  int _selectedNavIndex = -1;
  bool _focusShield = true;
  String _filterLevel = 'Medium';
  String _userId = '';

  late List<Map<String, dynamic>> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = [
      {
        'label': 'Morning Routine',
        'time': '6:00 AM - 8:00 AM',
        'days': 'Mon Tue Wed Thu Fri',
        'active': true,
      },
      {
        'label': 'Study Time',
        'time': '9:00 AM - 12:00 PM',
        'days': 'Mon Tue Wed Thu Fri',
        'active': true,
      },
      {
        'label': 'Evening Focus',
        'time': '2:00 PM - 5:00 PM',
        'days': 'Sat Sun',
        'active': false,
      },
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(localStorageServiceProvider);
      final userId = (await storage.readUserId()) ?? '';
      if (mounted && userId.isNotEmpty) {
        _userId = userId;
        setState(() {});
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    // Store context as local variable to pass to dialog methods
    final buildContext = context;
    
    if (_userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final disciplineState = ref.watch(disciplineNotifierProvider(_userId));
    
    final apps = disciplineState.whenData((data) {
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings == null) return <Map<String, dynamic>>[];
      // Return formatted apps list from backend
      return <Map<String, dynamic>>[]; // Placeholder - would be populated from backend
    }).valueOrNull ?? <Map<String, dynamic>>[];

    final blockedApps = apps.where((a) => a['blocked'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: ProfileViewShell(
        child: SafeArea(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discipline',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Syne',
                              fontSize: 39,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB284BE),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB284BE).withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 26),
                        onPressed: () => _showScheduleMenu(buildContext, ref, _userId),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '5.6h saved today from distractions',
                  style: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontFamily: 'Syne',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: _focusShield
                        ? const Color(0xFFB284BE).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: _focusShield
                          ? const Color(0xFFB284BE).withValues(alpha: 0.28)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _focusShield
                              ? const Color(0xFFB284BE).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _focusShield
                                ? const Color(0xFFB284BE).withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: _focusShield ? const Color(0xFFB284BE) : Colors.white54,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Focus Shield',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Blocking $blockedApps apps right now',
                              style: const TextStyle(
                                color: Color(0x99FFFFFF),
                                fontFamily: 'Syne',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _profileToggle(
                        value: _focusShield,
                        onChanged: (v) => setState(() => _focusShield = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard('5.6h', 'Time saved', const Color(0xFF4ADE80), Icons.trending_up),
                    const SizedBox(width: 10),
                    _statCard('$blockedApps', 'Apps blocked', const Color(0xFFB284BE), Icons.lock_outline),
                    const SizedBox(width: 10),
                    _statCard('84%', 'Focus score', const Color(0xFFA2ADD0), Icons.flash_on),
                  ],
                ),
                const SizedBox(height: 14),
                _buildWeeklyChart(),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('Blocked Apps'),
                    GestureDetector(
                      onTap: () => _showAddAppDialog(buildContext, ref, _userId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _panel(
                  children: [
                    _blockedAppsList(ref, _userId),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle('Blocked Websites'),
                    GestureDetector(
                      onTap: () => _showAddWebsiteDialog(buildContext, ref, _userId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _panel(
                  children: [
                    _blockedWebsitesList(ref, _userId),
                  ],
                ),
                const SizedBox(height: 18),
                _sectionTitle('AI Content Filter'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8B878).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF8B878), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filter Level',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _filterDescription(_filterLevel),
                                style: const TextStyle(
                                  color: Color(0x99FFFFFF),
                                  fontFamily: 'Syne',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _filterLevel,
                          dropdownColor: const Color(0xFF20181F),
                          style: const TextStyle(color: Color(0xFFF8B878), fontFamily: 'Syne', fontWeight: FontWeight.w700),
                          underline: const SizedBox.shrink(),
                          items: const ['Off', 'Low', 'Medium', 'High', 'Strict']
                              .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _filterLevel = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _sectionTitle('Block Schedules'),
                _panel(
                  children: _schedules.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isActive = s['active'] as bool;
                    return _toggleRow(
                      title: s['label'] as String,
                      subtitle: s['time'] as String,
                      leading: Icon(
                        Icons.schedule_outlined,
                        color: isActive ? const Color(0xFF4ADE80) : Colors.white54,
                        size: 18,
                      ),
                      value: isActive,
                      onChanged: (v) => setState(() => _schedules[i]['active'] = v),
                      trailing: _buildDayChips(s['days'] as String),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                _sectionTitle('Prayer Times'),
                _buildPrayerTimesSection(ref),
                const SizedBox(height: 24),
                if (_focusShield)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.wifi, color: Color(0xFF4ADE80), size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Website Blocking Active',
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Social media and entertainment sites are blocked during your scheduled focus sessions. Stay strong! 💪',
                                style: TextStyle(
                                  color: Color(0x99FFFFFF),
                                  fontFamily: 'Syne',
                                  fontSize: 12,
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
            ),
        ),
      bottomNavigationBar: UnifiedBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavItemTapped: (index) {
          setState(() => _selectedNavIndex = index);
        },
        isPositioned: false,
      ),
    );
  }

  // Helper to render blocked apps list
  Widget _blockedAppsList(WidgetRef ref, String userId) {
    // For now, render hardcoded UI but wire actions to backend
    final sampleApps = [
      {'name': 'Instagram', 'icon': '📱', 'blocked': true},
      {'name': 'TikTok', 'icon': '🎵', 'blocked': true},
      {'name': 'YouTube', 'icon': '▶️', 'blocked': false},
    ];
    
    return Column(
      children: sampleApps.map((app) {
        return _toggleRow(
          title: app['name'] as String,
          subtitle: app['blocked'] == true ? 'Blocked' : 'Not restricted',
          leading: Text(app['icon'] as String, style: const TextStyle(fontSize: 20)),
          value: app['blocked'] as bool,
          onChanged: (v) async {
            // Wire to backend if needed
          },
        );
      }).toList(),
    );
  }

  // Helper to render blocked websites list
  Widget _blockedWebsitesList(WidgetRef ref, String userId) {
    final sampleSites = [
      {'domain': 'facebook.com', 'category': 'Social Media', 'blocked': true},
      {'domain': 'twitter.com', 'category': 'Social Media', 'blocked': true},
      {'domain': 'youtube.com', 'category': 'Entertainment', 'blocked': false},
    ];
    
    return Column(
      children: sampleSites.map((site) {
        return _toggleRow(
          title: site['domain'] as String,
          subtitle: site['category'] as String,
          leading: const Icon(Icons.public_outlined, color: Colors.white54, size: 18),
          value: site['blocked'] as bool,
          onChanged: (v) async {
            // Wire to backend if needed
          },
        );
      }).toList(),
    );
  }
}

  // Original helper methods below
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0x77FFFFFF),
          fontFamily: 'Syne',
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _panel({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required Widget leading,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: leading),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontFamily: 'Syne',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _profileToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: trailing,
            ),
          ),
        const Divider(height: 1, color: Color(0x11FFFFFF)),
      ],
    );
  }

  Widget _profileToggle({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? const Color(0xFFB284BE) : Colors.white.withValues(alpha: 0.1),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: const Color(0xFFB284BE).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0x99FFFFFF),
                fontFamily: 'Syne',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _filterDescription(String level) {
    switch (level) {
      case 'Off':
        return 'No content filtering.';
      case 'Low':
        return 'Blocks explicit content only.';
      case 'High':
        return 'Strict safety and distraction blocking.';
      case 'Strict':
        return 'Maximum moderation on all content.';
      default:
        return 'Moderate – blocks adult & violent content.';
    }
  }

  Widget _buildDayChips(String daysString) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: dayLabels.map((day) {
          final isSelected = daysString.contains(day);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFB284BE).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB284BE).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFB284BE) : const Color(0x77FFFFFF),
                    fontFamily: 'Syne',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    const double maxVal = 4.1;
    final List<Map<String, dynamic>> weekly = [
      {'d': 'M', 'v': 3.2},
      {'d': 'T', 'v': 2.8},
      {'d': 'W', 'v': 4.1},
      {'d': 'T', 'v': 1.9},
      {'d': 'F', 'v': 3.7},
      {'d': 'S', 'v': 0.8},
      {'d': 'S', 'v': 1.2},
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF4ADE80), size: 18),
              SizedBox(width: 8),
              Text(
                'Hours Saved This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekly.map((e) {
                final v = (e['v'] as double);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (v / maxVal) * 66,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e['d'] as String,
                          style: const TextStyle(
                            color: Color(0x66FFFFFF),
                            fontFamily: 'Syne',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total saved',
                style: TextStyle(color: Color(0x77FFFFFF), fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Text(
                    '17.7h',
                    style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'vs last week',
                    style: TextStyle(color: Color(0x77FFFFFF), fontFamily: 'Syne', fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '+23%',
                    style: TextStyle(color: Color(0xFF4ADE80), fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScheduleMenu(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF20181F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Syne',
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _menuItem('Add Focus Schedule', Icons.schedule, () {
              Navigator.pop(context);
              _showAddScheduleDialog(context, ref, userId);
            }),
            _menuItem('Add App to Block', Icons.apps, () {
              Navigator.pop(context);
              _showAddAppDialog(context, ref, userId);
            }),
            _menuItem('Add Website to Block', Icons.public, () {
              Navigator.pop(context);
              _showAddWebsiteDialog(context, ref, userId);
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAppDialog(BuildContext context, WidgetRef ref, String userId) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF20181F),
        title: const Text(
          'Add App to Block',
          style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'App name (e.g. Instagram)',
                  hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'App URL or package name',
                  hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0x77FFFFFF))),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                await ref.read(disciplineNotifierProvider(userId).notifier).addBlockedApp(
                  nameController.text,
                  urlController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFFB284BE), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddWebsiteDialog(BuildContext context, WidgetRef ref, String userId) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF20181F),
        title: const Text(
          'Add Website to Block',
          style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Website name (e.g. Facebook)',
                  hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Domain (e.g. facebook.com)',
                  hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0x77FFFFFF))),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                await ref.read(disciplineNotifierProvider(userId).notifier).addBlockedWebsite(
                  nameController.text,
                  urlController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFFB284BE), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref, String userId) {
    final labelController = TextEditingController();
    final timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF20181F),
        title: const Text(
          'Add Focus Schedule',
          style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Schedule name',
                hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Time (e.g. 09:00 - 12:00)',
                hintStyle: const TextStyle(color: Color(0x77FFFFFF)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0x77FFFFFF))),
          ),
          TextButton(
            onPressed: () async {
              if (labelController.text.isNotEmpty && timeController.text.isNotEmpty) {
                await ref.read(disciplineNotifierProvider(userId).notifier).updateSchedule(
                  labelController.text,
                  timeController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFFB284BE), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection(WidgetRef ref) {
    final faithModeState = ref.watch(faithModeSettingsProvider);
    
    if (!faithModeState.enabled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D6BB4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.more_time_rounded, color: Color(0xFF9D6BB4), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Faith Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Enable to see prayer times and add them to your schedule',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFamily: 'Syne',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ref.read(faithModeSettingsProvider.notifier).toggleFaithMode(true);
                  },
                  child: Container(
                    width: 48,
                    height: 28,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
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

    // Faith mode enabled - show prayer times
    if (faithModeState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF9D6BB4)),
        ),
      );
    }

    if (faithModeState.error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Could not load prayer times',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        faithModeState.error ?? 'Unknown error',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFamily: 'Syne',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (faithModeState.city != null && faithModeState.country != null) {
                    ref.read(faithModeSettingsProvider.notifier)
                        .fetchPrayerTimes(faithModeState.city!, faithModeState.country!);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF9D6BB4).withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Color(0xFF9D6BB4),
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Display prayer times
    return _panel(
      children: [
        if (faithModeState.prayerTimes != null && faithModeState.prayerTimes!.isNotEmpty)
          ...faithModeState.prayerTimes!.map((prayer) {
            return _toggleRow(
              title: prayer.name,
              subtitle: prayer.time,
              leading: const Icon(Icons.more_time, color: Color(0xFF9D6BB4), size: 18),
              value: true,
              onChanged: (_) {
                // Mark as prayer schedule block
              },
            );
          }),
      ],
    );
  }


