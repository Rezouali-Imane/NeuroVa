import 'package:dio/dio.dart';

import '../../../shared/services/local_storage_service.dart';
import '../models/task_model.dart';

class TasksService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  static const Duration _standardConnectTimeout = Duration(seconds: 12);
  static const Duration _standardReceiveTimeout = Duration(seconds: 20);

  TasksService(this._dio, this._localStorageService);

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

  Future<String> _resolveTaskListId({
    required String userId,
    required String requestedListId,
  }) async {
    if (requestedListId.trim().isNotEmpty && requestedListId != 'default') {
      return requestedListId;
    }

    final headers = await _getHeaders();

    final listsResponse = await _dio.get<dynamic>(
      '/api/tasklists/user/$userId',
      options: _requestOptions(headers),
    );

    if (listsResponse.statusCode == 200 && listsResponse.data is Map<String, dynamic>) {
      final payload = listsResponse.data as Map<String, dynamic>;
      final lists = payload['data'] as List<dynamic>? ?? const [];
      if (lists.isNotEmpty) {
        final first = lists.first;
        if (first is Map<String, dynamic>) {
          final listId = first['listid']?.toString();
          if (listId != null && listId.isNotEmpty) {
            return listId;
          }
        }
      }
    }

    final createResponse = await _dio.post<dynamic>(
      '/api/tasklists',
      data: {
        'userid': userId,
        'name': 'My Tasks',
      },
      options: _requestOptions(headers),
    );

    if (createResponse.statusCode == 201 && createResponse.data is Map<String, dynamic>) {
      final payload = createResponse.data as Map<String, dynamic>;
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final listId = data['listid']?.toString();
        if (listId != null && listId.isNotEmpty) {
          return listId;
        }
      }
    }

    throw Exception('Unable to resolve task list');
  }

  Future<List<Task>> getTasks(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/tasks/user/$userId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final dataList = data['data'] as List<dynamic>?;
        if (dataList == null) {
          return [];
        }

        return dataList
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to fetch tasks');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error fetching tasks'));
    }
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    required String listId,
    String? description,
    DateTime? deadline,
    int priority = 1,
    String status = 'PENDING',
    String category = 'OTHER',
  }) async {
    try {
      final headers = await _getHeaders();
      final resolvedListId = await _resolveTaskListId(
        userId: userId,
        requestedListId: listId,
      );

      final response = await _dio.post<dynamic>(
        '/api/tasks',
        data: {
          'userid': userId,
          'listid': resolvedListId,
          'title': title,
          'description': description,
          'deadline': deadline?.toIso8601String(),
          'priority': priority,
          'status': status,
          'category': category,
        },
        options: _requestOptions(headers),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to create task');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error creating task'));
    }
  }

  Future<Task> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch<dynamic>(
        '/api/tasks/$taskId/status',
        data: {'status': status},
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to update task status');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error updating task status'));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete<dynamic>(
        '/api/tasks/$taskId',
        options: _requestOptions(headers),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      throw Exception(_readApiError(error, 'Error deleting task'));
    }
  }

  Future<Task> getTaskById(String taskId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get<dynamic>(
        '/api/tasks/$taskId',
        options: _requestOptions(headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch task');
    } catch (error) {
      throw Exception(_readApiError(error, 'Error fetching task'));
    }
  }
}
