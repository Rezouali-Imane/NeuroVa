import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/foucs_session_services.dart';
import '../Models/focus_session_module.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../auth/state/auth_notifier.dart';

// --- Provider setup ----------------------------------------------------------
final focusSessionServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
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

final activeFocusProvider = StateNotifierProvider<ActiveFocusNotifier, ActiveFocusState>((ref) {
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
      final result = await _service.createSession(userId: userId, timerSettings: settings);
      final session = FocusSession.fromJson(result);
      final timerMap = result['timer'] as Map<String, dynamic>;
      final timer = TimerSettings.fromJson(timerMap);
      _currentTimerId = timerMap['timerid'].toString();
      _initialDuration = timer.durationminutes * 60;
      state = ActiveFocusState(
        session: session,
        timer: timer,
        remainingSeconds: _initialDuration,
        isRunning: true,
        isLoading: false,
      );
      _startTicker();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
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
    });
  }

  Future<void> _completeSession() async {
    if (state.session == null) return;
    await _service.endSession(state.session!.sessionid);
    // After completion, reset local state
    state = ActiveFocusState(remainingSeconds: 0, isRunning: false);
    _timer?.cancel();
    _currentTimerId = null;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}