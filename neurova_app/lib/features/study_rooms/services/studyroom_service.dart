import 'package:dio/dio.dart';
import '../../../shared/services/local_storage_service.dart';
import '../models/studyroom_module.dart';

class StudyRoomService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  static const Duration _standardConnectTimeout = Duration(seconds: 12);
  static const Duration _standardReceiveTimeout = Duration(seconds: 20);

  StudyRoomService(this._dio, this._localStorageService);

  Future<String?> _getAuthToken() async {
    return _localStorageService.readAuthToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Options _requestOptions(Map<String, String> headers) {
    return Options(
      headers: headers,
      sendTimeout: _standardConnectTimeout,
      receiveTimeout: _standardReceiveTimeout,
    );
  }

  String _readApiError(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
      return error.message ?? fallback;
    }
    return error.toString();
  }

  Future<List<StudyRoom>> getRooms() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/studyrooms',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        final dataList = data['data'] as List<dynamic>? ?? [];
        return dataList
            .map((item) => StudyRoom.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to fetch rooms');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error fetching rooms'));
    }
  }

  Future<StudyRoom> createRoom({
    required String roomname,
    required String subject,
    required String focusmode,
    int maxparticipants = 10,
    bool ispublic = true,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/studyrooms',
        data: {
          'roomname': roomname,
          'subject': subject,
          'focusmode': focusmode,
          'maxparticipants': maxparticipants,
          'ispublic': ispublic,
          'sessionduration': 60,
        },
        options: _requestOptions(headers),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return StudyRoom.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to create study room');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error creating study room'));
    }
  }

  Future<Map<String, dynamic>> joinRoom(String roomcode) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/studyrooms/join/$roomcode',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return data;
      }

      throw Exception('Failed to join study room');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error joining study room'));
    }
  }

  Future<Map<String, dynamic>> leaveRoom(String roomid) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete<dynamic>(
        '/api/studyrooms/$roomid/leave',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return data;
      }

      throw Exception('Failed to leave study room');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error leaving study room'));
    }
  }

  Future<Map<String, dynamic>> startSession(String roomid) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/studyrooms/$roomid/start',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return data;
      }

      throw Exception('Failed to start session');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error starting session'));
    }
  }

  Future<Map<String, dynamic>> endSession(String roomid) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/studyrooms/$roomid/end',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return data;
      }

      throw Exception('Failed to end session');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error ending session'));
    }
  }
}