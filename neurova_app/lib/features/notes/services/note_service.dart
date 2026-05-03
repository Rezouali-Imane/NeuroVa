import 'package:dio/dio.dart';
import '../../../shared/services/local_storage_service.dart';
import '../models/note_module.dart';

class NotesService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  static const Duration _standardConnectTimeout = Duration(seconds: 12);
  static const Duration _standardReceiveTimeout = Duration(seconds: 20);

  NotesService(this._dio, this._localStorageService);

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

  Future<List<Note>> getNotes(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/notes/user/$userId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        final dataList = data['data'] as List<dynamic>? ?? [];
        return dataList
            .map((item) => Note.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to fetch notes');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error fetching notes'));
    }
  }

  Future<Note> createNote({
    required String userId,
    required String title,
    String? content,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post<dynamic>(
        '/api/notes',
        data: {
          'userid': userId,
          'title': title,
          'content': content,
        },
        options: _requestOptions(headers),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return Note.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to create note');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error creating note'));
    }
  }

  Future<Note> updateNote({
    required String noteId,
    required String title,
    String? content,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put<dynamic>(
        '/api/notes/$noteId',
        data: {
          'title': title,
          'content': content,
        },
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return Note.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to update note');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error updating note'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete<dynamic>(
        '/api/notes/$noteId',
        options: _requestOptions(headers),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete note');
      }
    } catch (error) {
      throw Exception(_readApiError(error, 'Error deleting note'));
    }
  }
}