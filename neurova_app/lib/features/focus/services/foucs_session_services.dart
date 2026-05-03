import 'package:dio/dio.dart';
import '../../../shared/services/local_storage_service.dart';
import '../Models/focus_session_module.dart';

class FocusSessionService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  FocusSessionService(this._dio, this._localStorageService);

  Future<String?> _getAuthToken() async => _localStorageService.readAuthToken();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Options _options() => Options(sendTimeout: Duration(seconds: 12), receiveTimeout: Duration(seconds: 20));

Future<Map<String, dynamic>> createSession({
  required String userId,
  required TimerSettings timerSettings,
}) async {
  final headers = await _getHeaders();
  final response = await _dio.post(
    '/api/focus-sessions',
    data: {
      'userid': userId,
      'starttime': DateTime.now().toUtc().toIso8601String(),
      'scheduleid': null,
      'roomid': null,
      'allowbreakminutes': 0,
      'timerSettings': timerSettings.toJson(),
    },
    options: _options().copyWith(headers: headers),
  );
  return response.data['data'];
}

  /// Update timer (remaining seconds and running state)
  Future<void> updateTimer(String timerId, int remainingSeconds, bool isRunning) async {
    final headers = await _getHeaders();
    await _dio.patch(
      '/api/focus-sessions/$timerId/timer',
      data: {
        'remainingseconds': remainingSeconds,
        'isrunning': isRunning,
      },
      options: _options().copyWith(headers: headers),
    );
  }

  /// End session (mark as COMPLETED)
  Future<void> endSession(String sessionId) async {
    final headers = await _getHeaders();
    await _dio.post('/api/focus-sessions/$sessionId/end', options: _options().copyWith(headers: headers));
  }

  /// Delete session (used when resetting before completion)
  Future<void> deleteSession(String sessionId) async {
    final headers = await _getHeaders();
    await _dio.delete('/api/focus-sessions/$sessionId', options: _options().copyWith(headers: headers));
  }

  /// Get all user sessions (for stats)
  Future<List<FocusSession>> getUserSessions(String userId) async {
    final headers = await _getHeaders();
    final response = await _dio.get(
      '/api/focus-sessions/user/$userId',
      options: _options().copyWith(headers: headers),
    );
    final List data = response.data['data'];
    return data.map((json) => FocusSession.fromJson(json)).toList();
  }
}