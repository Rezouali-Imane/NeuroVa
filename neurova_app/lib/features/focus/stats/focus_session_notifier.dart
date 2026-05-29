import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/foucs_session_services.dart';
import '../Models/focus_session_module.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../auth/state/auth_notifier.dart';
import '../../gamification/state/gamification_notifier.dart';

// --- Provider setup ----------------------------------------------------------
final focusSessionServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return FocusSessionService(dio, localStorage);
});

// State for the active session (the one currently running)
class ActiveFocusState {
  final FocusSession? session;
  final TimerSettings? timer;
  final int remainingSeconds;
  final bool isRunning;
  final bool isLoading;
  final String? error;

  ActiveFocusState({
    this.session,
    this.timer,
    required this.remainingSeconds,
    required this.isRunning,
    this.isLoading = false,
    this.error,
  });

  ActiveFocusState copyWith({
    FocusSession? session,
    TimerSettings? timer,
    int? remainingSeconds,
    bool? isRunning,
    bool? isLoading,
    String? error,
  }) {
    return ActiveFocusState(
      session: session ?? this.session,
      timer: timer ?? this.timer,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final activeFocusProvider =
    StateNotifierProvider<ActiveFocusNotifier, ActiveFocusState>((ref) {
      final service = ref.watch(focusSessionServiceProvider);
      final localStorage = ref.watch(localStorageServiceProvider);
      return ActiveFocusNotifier(service, localStorage, ref);
    });

class ActiveFocusNotifier extends StateNotifier<ActiveFocusState> {
  final FocusSessionService _service;
  final LocalStorageService _localStorage;
  final Ref _ref;
  Timer? _timer;
  String? _currentTimerId;
  int _initialDuration = 0;

  ActiveFocusNotifier(this._service, this._localStorage, this._ref)
    : super(ActiveFocusState(remainingSeconds: 0, isRunning: false));

  Future<String?> _getUserId() async => await _localStorage.readUserId();

  /// Start a new session with given timer settings (type, duration etc.)
  Future<void> startNewSession(TimerSettings settings) async {
    final userId = await _getUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.createSession(
        userId: userId,
        timerSettings: settings,
      );
      final session = FocusSession.fromJson(result);
      final timerMap = result['timer'] as Map<String, dynamic>;
      final timer = TimerSettings.fromJson(timerMap);
      _currentTimerId = timerMap['timerid'].toString();
      _initialDuration = timer.remainingseconds > 0
          ? timer.remainingseconds
          : timer.durationminutes * 60;
      state = ActiveFocusState(
        session: session,
        timer: timer,
        remainingSeconds: _initialDuration,
        isRunning: true,
        isLoading: false,
      );
      await _ref.read(sessionHistoryProvider.notifier).fetchSessions();
      _startTicker();
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint(' Backend error: ${e.response?.data}');
      } else {
        debugPrint(' startNewSession error: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      // For stopwatch, increment time; for countdown modes, decrement
      final isStopwatch = state.timer?.type == 'CHRONOMETER';
      
      if (isStopwatch) {
        // Stopwatch increments indefinitely until manually stopped
        final newSeconds = state.remainingSeconds + 1;
        state = state.copyWith(remainingSeconds: newSeconds);
        if (_currentTimerId != null) {
          await _service.updateTimer(_currentTimerId!, newSeconds, true);
        }
      } else {
        // Countdown modes decrement until time expires
        if (state.remainingSeconds <= 0) {
          _timer?.cancel();
          await _completeSession();
          return;
        }
        final newSeconds = state.remainingSeconds - 1;
        state = state.copyWith(remainingSeconds: newSeconds);
        if (_currentTimerId != null) {
          await _service.updateTimer(_currentTimerId!, newSeconds, true);
        }
      }
    });
  }

  Future<void> _completeSession() async {
    if (state.session == null) return;
    final sessionId = state.session!.sessionid;
    final focusedSeconds = _initialDuration - state.remainingSeconds;
    final focusMinutes = (focusedSeconds / 60).ceil().clamp(0, 9999);

    await _service.endSession(sessionId);

    state = ActiveFocusState(remainingSeconds: 0, isRunning: false);
    _timer?.cancel();
    _currentTimerId = null;

    await _ref.read(sessionHistoryProvider.notifier).fetchSessions();

    _ref.read(gamificationNotifierProvider.notifier).calculateFocusScore(
      sessionId: sessionId,
      focusMinutes: focusMinutes,
      breakMinutes: 0,
      tasksCompleted: 0,
    );
  }

  Future<void> endSession() async {
    if (state.session == null) return;
    final sessionId = state.session!.sessionid;
    final focusedSeconds = _initialDuration - state.remainingSeconds;
    final focusMinutes = (focusedSeconds / 60).ceil().clamp(0, 9999);

    _timer?.cancel();
    await _service.endSession(sessionId);
    state = ActiveFocusState(remainingSeconds: 0, isRunning: false);
    _currentTimerId = null;

    await _ref.read(sessionHistoryProvider.notifier).fetchSessions();

    _ref.read(gamificationNotifierProvider.notifier).calculateFocusScore(
      sessionId: sessionId,
      focusMinutes: focusMinutes,
      breakMinutes: 0,
      tasksCompleted: 0,
    );
  }

  void pause() {
    if (!state.isRunning) return;
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    if (_currentTimerId != null) {
      _service.updateTimer(_currentTimerId!, state.remainingSeconds, false);
    }
  }

  void resume() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _startTicker();
  }

  Future<void> reset() async {
    _timer?.cancel();
    if (state.session != null && _currentTimerId != null) {
      await _service.deleteSession(state.session!.sessionid);
    }
    state = ActiveFocusState(remainingSeconds: 0, isRunning: false);
    _currentTimerId = null;
    await _ref.read(sessionHistoryProvider.notifier).fetchSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// State for session history
class SessionHistoryState {
  final List<FocusSession> sessions;
  final bool isLoading;

  SessionHistoryState({this.sessions = const [], this.isLoading = false});

  SessionHistoryState copyWith({
    List<FocusSession>? sessions,
    bool? isLoading,
  }) {
    return SessionHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // total minutes focused today
  int get todayMinutes {
    final today = DateTime.now();
    return sessions
        .where(
          (s) =>
              s.status == 'COMPLETED' &&
              s.starttime.toLocal().year == today.year &&
              s.starttime.toLocal().month == today.month &&
              s.starttime.toLocal().day == today.day,
        )
        .fold(0, (sum, s) => sum + (s.duration ?? 0));
  }

  int get streakDays {
    final completedDays = sessions
        .where((s) => s.status == 'COMPLETED')
        .map((s) {
          final local = s.starttime.toLocal();
          return DateTime(local.year, local.month, local.day);
        })
        .toSet();

    if (completedDays.isEmpty) return 0;

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var streak = 0;

    while (completedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // total minutes this week
  int get weekMinutes {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return sessions
        .where((s) => s.status == 'COMPLETED' && s.starttime.toLocal().isAfter(weekStart))
        .fold(0, (sum, s) => sum + (s.duration ?? 0));
  }

  // best day this week
  String get bestDay {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<int, int> minutesByDay = {};
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    for (final s in sessions) {
      if (s.status == 'COMPLETED') {
        final localStart = s.starttime.toLocal();
        if (localStart.isBefore(weekStart) || !localStart.isBefore(weekEnd)) {
          continue;
        }
        final day = localStart.weekday; // 1=Mon, 7=Sun
        minutesByDay[day] = (minutesByDay[day] ?? 0) + (s.duration ?? 0);
      }
    }
    if (minutesByDay.isEmpty) return '-';
    final best = minutesByDay.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return days[best.key - 1];
  }

  // daily average this week
  int get weekDailyAvgMinutes {
    final days = weekMinutes > 0 ? 7 : 1;
    return weekMinutes ~/ days;
  }
}

final sessionHistoryProvider =
    StateNotifierProvider<SessionHistoryNotifier, SessionHistoryState>((ref) {
      final service = ref.watch(focusSessionServiceProvider);
      final localStorage = ref.watch(localStorageServiceProvider);
      return SessionHistoryNotifier(service, localStorage);
    });

class SessionHistoryNotifier extends StateNotifier<SessionHistoryState> {
  final FocusSessionService _service;
  final LocalStorageService _localStorage;

  SessionHistoryNotifier(this._service, this._localStorage)
    : super(SessionHistoryState());

  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = await _localStorage.readUserId() ?? '';
      final sessions = await _service.getUserSessions(userId);
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
