import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/services/local_storage_service.dart';

class GoogleCalendarService {
  final Dio _dio;
  final LocalStorageService _localStorage;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/calendar'],
    serverClientId: '21482377248-p28kgvusk83sufe5dn1dvga8esuspm8b.apps.googleusercontent.com',
  );

  GoogleCalendarService(this._dio, this._localStorage);

  Future<Options> _options() async {
    final token = await _localStorage.readAuthToken();
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      sendTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
    );
  }

  String _readError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      return e.message ?? fallback;
    }
    return e.toString();
  }

  Future<void> connectGoogleCalendar() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Google sign-in cancelled');

      final authCode = account.serverAuthCode;
      if (authCode == null) throw Exception('No auth code received from Google');

      await _dio.post<dynamic>(
        '/api/google-calendar/connect',
        data: {'code': authCode},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to connect Google Calendar'));
    }
  }

  Future<void> disconnectGoogleCalendar() async {
    try {
      await _googleSignIn.signOut();
      await _dio.post<dynamic>(
        '/api/google-calendar/disconnect',
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to disconnect Google Calendar'));
    }
  }

  Future<void> syncTaskToGoogle(String taskId) async {
    try {
      await _dio.post<dynamic>(
        '/api/google-calendar/sync-task-to-google',
        data: {'taskid': taskId},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to sync task to Google'));
    }
  }

  Future<void> syncGoogleToTask(String eventId, String listId) async {
    try {
      await _dio.post<dynamic>(
        '/api/google-calendar/sync-google-to-task',
        data: {'eventid': eventId, 'listid': listId},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to sync Google event to task'));
    }
  }

  Future<void> deleteGoogleEvent(String eventId, String taskId) async {
    try {
      await _dio.post<dynamic>(
        '/api/google-calendar/delete-google-event',
        data: {'eventid': eventId, 'taskid': taskId},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to delete Google event'));
    }
  }

  Future<void> updateCalendarEvent(String taskId) async {
    try {
      await _dio.patch<dynamic>(
        '/api/google-calendar/update-event',
        data: {'taskid': taskId},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to update calendar event'));
    }
  }

  Future<void> fullSync(String listId) async {
    try {
      await _dio.post<dynamic>(
        '/api/google-calendar/full-sync',
        data: {'listid': listId},
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Full sync failed'));
    }
  }
}