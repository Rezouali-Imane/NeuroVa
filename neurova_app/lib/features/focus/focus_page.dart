import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/profile_view_shell.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import '../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../gamification/state/gamification_notifier.dart';
import './stats/focus_session_notifier.dart';
import './Models/focus_session_module.dart';

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key});

  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage> {
  int _selectedNavIndex = 2;
  String _mode = 'Pomodoro';
  bool _ambientOn = true;

  // Pomodoro settings
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;

  // Countdown settings
  int _countdownMinutes = 30;
  int _countdownSeconds = 0;

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeFocusProvider);
    final hasActiveSession = activeState.session != null;
    final isRunning = activeState.isRunning;
    final remainingSeconds = activeState.remainingSeconds;
    final totalXp = ref.watch(gamificationNotifierProvider).totalXp;
    final initialSeconds = _getInitialSeconds();

    // Show timer display value
    String displayTime;
    if (hasActiveSession) {
      displayTime = _formatTime(remainingSeconds);
    } else {
      displayTime = _formatTime(initialSeconds);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: ProfileViewShell(
        child: Stack(
          children: [
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // Header (stats placeholder – can be extended later)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Today · 0 sessions',
                              style: TextStyle(color: Color(0x72FFFFFF), fontFamily: 'Syne', fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Focus',
                              style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontSize: 56 / 1.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0x1FF8B878),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0x55F8B878)),
                        ),
                        child: Text(
                          '⚡ $totalXp XP',
                          style: const TextStyle(color: Color(0xFFF3C57D), fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mode selector
                  Row(
                    children: ['Pomodoro', 'Countdown', 'Stopwatch']
                        .map((mode) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    if (hasActiveSession) {
                                      // Optionally show a message that you cannot switch mode mid-session
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please finish or reset current session first')),
                                      );
                                      return;
                                    }
                                    setState(() => _mode = mode);
                                  },
                                  child: Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _mode == mode ? const Color(0x1BB284BE) : const Color(0xFF1A1628),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _mode == mode ? const Color(0x88B284BE) : const Color(0xFF2B2550),
                                      ),
                                    ),
                                    child: Text(
                                      mode,
                                      style: TextStyle(
                                        color: _mode == mode ? const Color(0xFFCEA4D4) : Colors.white54,
                                        fontFamily: 'Syne',
                                        fontSize: 12,
                                        fontWeight: _mode == mode ? FontWeight.w700 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  // Timer ring (tappable for customisation)
                  GestureDetector(
                    onTap: () {
                      if (hasActiveSession) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot change settings during an active session')),
                        );
                        return;
                      }
                      _openTimerCustomizer();
                    },
                    child: SizedBox(
                      height: 292,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 282,
                            height: 282,
                            child: CustomPaint(
                              painter: _RingPainter(
                                progress: hasActiveSession && initialSeconds > 0
                                    ? (1 - remainingSeconds / initialSeconds).clamp(0.0, 1.0)
                                    : 0.0,
                                color: _accent(),
                                backgroundColor: const Color(0xFF2A2545),
                                strokeWidth: 11,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    displayTime,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _accent(),
                                      fontFamily: 'Syne',
                                      fontSize: _mode == 'Stopwatch' ? 52 : 64,
                                      fontWeight: FontWeight.w800,
                                      height: 0.95,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _mode == 'Pomodoro' ? (hasActiveSession ? 'Focus' : 'Focus') : _mode,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0x82FFFFFF), fontFamily: 'Syne', fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (_mode == 'Pomodoro') ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: ['Focus', 'Short Break', 'Long Break']
                                        .map((phase) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: hasActiveSession ? _accent() : Colors.white24,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controlIconButton(
                        icon: const Icon(Icons.replay, color: Colors.white70),
                        onTap: () async {
                          if (hasActiveSession) {
                            // Reset current session
                            await ref.read(activeFocusProvider.notifier).reset();
                          } else {
                            // Start new session with current settings
                            await _startSessionForSelectedMode();
                          }
                        },
                      ),
                      const SizedBox(width: 22),
                      GestureDetector(
                        onTap: () async {
                          if (!hasActiveSession) {
                            await _startSessionForSelectedMode();
                          } else {
                            // Pause/Resume
                            if (isRunning) {
                              ref.read(activeFocusProvider.notifier).pause();
                            } else {
                              ref.read(activeFocusProvider.notifier).resume();
                            }
                          }
                        },
                        child: Container(
                          width: 104,
                          height: 104,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [_accent().withValues(alpha: 0.95), _accent().withValues(alpha: 0.72)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(color: _accent().withValues(alpha: 0.42), blurRadius: 28, offset: const Offset(0, 10))],
                          ),
                          child: Icon(
                            !hasActiveSession ? Icons.play_arrow : (isRunning ? Icons.pause : Icons.play_arrow),
                            color: const Color(0xFF1B1531),
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      _controlIconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white70),
                        onTap: () async {
                          if (hasActiveSession) {
                            // End session early
                            await ref.read(activeFocusProvider.notifier).reset(); // or call endSession directly
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  // Ambient sounds (local toggle only)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17132A),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF2B2550)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_down_rounded, color: Color(0xFFF3C57D)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ambient Sounds', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                              SizedBox(height: 2),
                              Text('Cafe', style: TextStyle(color: Color(0x82FFFFFF), fontFamily: 'Syne', fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _ambientOn = !_ambientOn),
                          child: Container(
                            width: 56,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _ambientOn ? const Color(0x26F3C57D) : const Color(0xFF211B37),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _ambientOn ? const Color(0x99F3C57D) : const Color(0xFF2B2550)),
                            ),
                            child: Text(
                              _ambientOn ? 'On' : 'Off',
                              style: TextStyle(
                                color: _ambientOn ? const Color(0xFFF3C57D) : Colors.white54,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Stats placeholder
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17132A),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF2B2550)),
                    ),
                    child: const Row(
                      children: [
                        Text('This Week', style: TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 16)),
                        Spacer(),
                        Text('0h 0m total', style: TextStyle(color: Color(0x82FFFFFF), fontFamily: 'Syne', fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
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

  // Helper: get initial seconds for idle state
  int _getInitialSeconds() {
    switch (_mode) {
      case 'Pomodoro':
        return _focusMinutes * 60;
      case 'Countdown':
        return (_countdownMinutes * 60) + _countdownSeconds;
      case 'Stopwatch':
        return 0;
      default:
        return 0;
    }
  }

  // Build TimerSettings object from current UI state
  TimerSettings _buildTimerSettings() {
    switch (_mode) {
      case 'Pomodoro':
        return TimerSettings(
          type: 'POMODORO',
          durationminutes: _focusMinutes,
          breakminutes: _shortBreakMinutes,
          longbreakminutes: _longBreakMinutes,
          pomodorocycles: 0,
          remainingseconds: _focusMinutes * 60,
          isrunning: true,
        );
      case 'Countdown':
        return TimerSettings(
          type: 'COUNTDOWN',
          durationminutes: _countdownMinutes,
          remainingseconds: (_countdownMinutes * 60) + _countdownSeconds,
          isrunning: true,
        );
      case 'Stopwatch':
        return TimerSettings(
          type: 'STOPWATCH',
          durationminutes: 0,
          remainingseconds: 0,
          isrunning: true,
        );
      default:
        throw Exception('Unknown mode');
    }
  }

  Future<void> _startSessionForSelectedMode() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final userId = await localStorage.readUserId();
    if (!mounted) return;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to start a focus session')),
      );
      return;
    }
    final settings = _buildTimerSettings();
    await ref.read(activeFocusProvider.notifier).startNewSession(settings);
    if (!mounted) return;
    final error = ref.read(activeFocusProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    }
  }

  // Open appropriate customiser based on current mode
  void _openTimerCustomizer() async {
    if (_mode == 'Pomodoro') {
      await _showPomodoroSettingsSheet();
    } else if (_mode == 'Countdown') {
      await _showCountdownSettingsSheet();
    } else {
      // Stopwatch has no settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stopwatch does not have custom settings')),
      );
    }
  }

  // Bottom sheet for Pomodoro settings (focus, short break, long break)
  Future<void> _showPomodoroSettingsSheet() async {
    int focus = _focusMinutes;
    int shortBreak = _shortBreakMinutes;
    int longBreak = _longBreakMinutes;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          Widget durationRow({
            required String title,
            required int value,
            required List<int> options,
            required ValueChanged<int> onChanged,
            required Color color,
          }) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0x66FFFFFF),
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options
                      .map(
                        (minutes) => GestureDetector(
                          onTap: () => setSheetState(() => onChanged(minutes)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: value == minutes ? color.withValues(alpha: 0.2) : const Color(0xFF1A1630),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: value == minutes ? color.withValues(alpha: 0.7) : const Color(0xFF2A2550),
                              ),
                            ),
                            child: Text(
                              '${minutes}m',
                              style: TextStyle(
                                color: value == minutes ? color : Colors.white54,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF201C36),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2A2550)),
                  ),
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Syne',
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 40),
            padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF17132E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pomodoro\nSettings',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          fontSize: 48 / 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF272149),
                          border: Border.all(color: const Color(0xFF312A5A)),
                        ),
                        child: const Icon(Icons.close, color: Colors.white54, size: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                durationRow(
                  title: 'FOCUS DURATION',
                  value: focus,
                  options: const [15, 20, 25, 30, 45, 60],
                  onChanged: (v) => focus = v,
                  color: const Color(0xFFB88BDD),
                ),
                const SizedBox(height: 16),
                durationRow(
                  title: 'SHORT BREAK',
                  value: shortBreak,
                  options: const [3, 5, 7, 10],
                  onChanged: (v) => shortBreak = v,
                  color: const Color(0xFFA8B6E2),
                ),
                const SizedBox(height: 16),
                durationRow(
                  title: 'LONG BREAK',
                  value: longBreak,
                  options: const [10, 15, 20, 25, 30],
                  onChanged: (v) => longBreak = v,
                  color: const Color(0xFFF3C57D),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _focusMinutes = focus;
                      _shortBreakMinutes = shortBreak;
                      _longBreakMinutes = longBreak;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)]),
                    ),
                    child: const Text(
                      'Apply Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Bottom sheet for countdown settings (minutes and seconds)
  Future<void> _showCountdownSettingsSheet() async {
    int minutes = _countdownMinutes;
    int seconds = _countdownSeconds;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void applyQuick(int m) {
            setSheetState(() {
              minutes = m;
              seconds = 0;
            });
          }

          Widget valueBox(String label, int value, ValueChanged<int> onChange) {
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0x66FFFFFF),
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 104,
                    decoration: BoxDecoration(
                      color: const Color(0xFF201C36),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2550)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => onChange(value + 1),
                          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white38),
                        ),
                        Text(
                          value.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Color(0xFFF3C57D),
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 34,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onChange(value > 0 ? value - 1 : 0),
                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 40),
            padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF17132E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Set Countdown',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF272149),
                          border: Border.all(color: const Color(0xFF312A5A)),
                        ),
                        child: const Icon(Icons.close, color: Colors.white54, size: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [15, 20, 25, 30, 45, 60, 90]
                      .map(
                        (m) => GestureDetector(
                          onTap: () => applyQuick(m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: minutes == m && seconds == 0
                                  ? const Color(0x24F3C57D)
                                  : const Color(0xFF1A1630),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: minutes == m && seconds == 0
                                    ? const Color(0x99F3C57D)
                                    : const Color(0xFF2A2550),
                              ),
                            ),
                            child: Text(
                              '${m}m',
                              style: TextStyle(
                                color: minutes == m && seconds == 0
                                    ? const Color(0xFFF3C57D)
                                    : Colors.white54,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    valueBox(
                      'MINUTES',
                      minutes,
                      (v) => setSheetState(() => minutes = v.clamp(0, 180)),
                    ),
                    const SizedBox(width: 12),
                    valueBox(
                      'SECONDS',
                      seconds,
                      (v) => setSheetState(() => seconds = v.clamp(0, 59)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _countdownMinutes = minutes;
                      _countdownSeconds = seconds;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFFF8B878), Color(0xFFE9A95C)]),
                    ),
                    child: const Text(
                      'Apply Countdown',
                      style: TextStyle(
                        color: Color(0xFF2A1A00),
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper: format time (mm:ss)
  String _formatTime(int seconds) {
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Accent colour depending on mode
  Color _accent() {
    if (_mode == 'Countdown') return const Color(0xFFF8B878);
    if (_mode == 'Stopwatch') return const Color(0xFFA2ADD0);
    return const Color(0xFFB284BE);
  }

  Widget _controlIconButton({required Widget icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF17132A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2B2550)),
        ),
        child: icon,
      ),
    );
  }
}

// Custom painter for the ring progress
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.2), color, color.withValues(alpha: 0.9)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 6.283185307179586, false, backgroundPaint);
    canvas.drawArc(rect, -1.5707963267948966, 6.283185307179586 * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}