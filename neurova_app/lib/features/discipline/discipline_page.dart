import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/theme/app_theme.dart' show AppTypography;

import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';

class DisciplinePage extends StatefulWidget {
  const DisciplinePage({super.key});

  @override
  State<DisciplinePage> createState() => _DisciplinePageState();
}

class _DisciplinePageState extends State<DisciplinePage> {
  int _selectedNavIndex = -1;
  bool _focusShield = true;
  String _filterLevel = 'Medium';
  final List<Map<String, dynamic>> _weekly = [
    {'d': 'M', 'v': 3.2},
    {'d': 'T', 'v': 2.8},
    {'d': 'W', 'v': 4.1},
    {'d': 'T', 'v': 1.9},
    {'d': 'F', 'v': 3.7},
    {'d': 'S', 'v': 0.8},
    {'d': 'S', 'v': 1.2},
  ];

  final List<Map<String, dynamic>> _schedules = [
    {'label': 'Morning Focus', 'time': '09:00 - 12:00', 'days': 'Mon Tue Wed Thu Fri', 'active': true},
    {'label': 'Afternoon Block', 'time': '14:00 - 17:00', 'days': 'Mon Wed Fri', 'active': true},
    {'label': 'Night Study', 'time': '20:00 - 23:00', 'days': 'Sun', 'active': false},
  ];

  final List<Map<String, dynamic>> _apps = [
    {'name': 'Instagram', 'icon': '📸', 'blocked': true, 'saved': '2h 14m'},
    {'name': 'TikTok', 'icon': '🎵', 'blocked': true, 'saved': '1h 38m'},
    {'name': 'YouTube', 'icon': '▶️', 'blocked': false, 'saved': '3h 02m'},
    {'name': 'Reddit', 'icon': '🟠', 'blocked': true, 'saved': '58m'},
  ];

  final List<Map<String, dynamic>> _sites = [
    {'domain': 'facebook.com', 'category': 'Social Media', 'blocked': true},
    {'domain': 'twitter.com', 'category': 'Social Media', 'blocked': true},
    {'domain': 'youtube.com', 'category': 'Entertainment', 'blocked': false},
    {'domain': 'netflix.com', 'category': 'Entertainment', 'blocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    final blockedApps = _apps.where((a) => a['blocked'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: ProfileViewShell(
        child: Stack(
          children: [
            SafeArea(
              child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                const Text(
                  'Discipline',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Syne',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$blockedApps apps currently blocked',
                  style: const TextStyle(
                    color: Color(0x66FFFFFF),
                    fontFamily: 'Syne',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: _focusShield
                          ? const [Color(0x30B284BE), Color(0x1AA2ADD0)]
                          : const [Color(0xFF1A1628), Color(0xFF1A1628)],
                    ),
                    border: Border.all(
                      color: _focusShield
                          ? const Color(0x55B284BE)
                          : const Color(0xFF2A2440),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _focusShield
                              ? const Color(0xFFB284BE)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: _focusShield ? const Color(0xFF13111A) : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Focus Shield',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Protects your focus by blocking distractions',
                              style: TextStyle(
                                color: Color(0x66FFFFFF),
                                fontFamily: 'Syne',
                                fontSize: 11,
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
                    _statCard('Time Saved', '8.1h', const Color(0xFF4ADE80)),
                    const SizedBox(width: 8),
                    _statCard('Blocked', '$blockedApps', const Color(0xFFB284BE)),
                    const SizedBox(width: 8),
                    _statCard('Focus Score', '84%', const Color(0xFFA2ADD0)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildWeeklyChart(),
                const SizedBox(height: 18),
                _sectionTitle('Blocked Apps'),
                _panel(
                  children: _apps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final app = entry.value;
                    return _toggleRow(
                      title: app['name'] as String,
                      subtitle: app['blocked'] == true
                          ? 'Blocked for ${app['saved']} today'
                          : 'Not restricted',
                      leading: Text(app['icon'] as String, style: const TextStyle(fontSize: 20)),
                      value: app['blocked'] as bool,
                      onChanged: (v) => setState(() => _apps[i]['blocked'] = v),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _sectionTitle('Blocked Websites'),
                _panel(
                  children: _sites.asMap().entries.map((entry) {
                    final i = entry.key;
                    final site = entry.value;
                    return _toggleRow(
                      title: site['domain'] as String,
                      subtitle: site['category'] as String,
                      leading: const Icon(Icons.public, color: Colors.white54, size: 18),
                      value: site['blocked'] as bool,
                      onChanged: (v) => setState(() => _sites[i]['blocked'] = v),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _sectionTitle('AI Content Filter'),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1628),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2440)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFF8B878)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filter Level',
                                style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _filterDescription(_filterLevel),
                                style: const TextStyle(color: Color(0x66FFFFFF), fontFamily: 'Syne', fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: _filterLevel,
                          dropdownColor: const Color(0xFF1A1628),
                          style: const TextStyle(color: Colors.white, fontFamily: 'Syne'),
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
                    return _toggleRow(
                      title: s['label'] as String,
                      subtitle: '${s['time']} · ${s['days']}',
                      leading: const Icon(Icons.schedule, color: Colors.white54, size: 18),
                      value: s['active'] as bool,
                      onChanged: (v) => setState(() => _schedules[i]['active'] = v),
                    );
                  }).toList(),
                ),
              ],
              ),
            ),
            UnifiedBottomNavBar(
              selectedIndex: _selectedNavIndex,
              onNavItemTapped: (index) {
                setState(() => _selectedNavIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0x55FFFFFF),
          fontFamily: 'Syne',
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _panel({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2440)),
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
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0x66FFFFFF), fontFamily: 'Syne', fontSize: 11),
                    ),
                  ],
                ),
              ),
              _profileToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFF2A2440)),
      ],
    );
  }

  Widget _profileToggle({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
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
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
        return 'Moderate filtering for adult and violent content.';
    }
  }

  Widget _buildWeeklyChart() {
    const double maxVal = 4.1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2440)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF4ADE80), size: 16),
              SizedBox(width: 6),
              Text(
                'Hours Saved This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weekly.map((e) {
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
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: 17.7h',
                style: TextStyle(color: Colors.white70, fontFamily: 'Syne', fontSize: 11),
              ),
              Text(
                '+23% vs last week',
                style: TextStyle(color: Color(0xFF4ADE80), fontFamily: 'Syne', fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
