import 'package:dio/dio.dart';
import '../../../shared/services/local_storage_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio;
  final LocalStorageService _localStorage;

  NotificationService(this._dio, this._localStorage);

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
        final msg = data['message'] ?? data['error'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      return e.message ?? fallback;
    }
    return e.toString();
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/notifications',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch notifications'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch<dynamic>(
        '/api/notifications/$notificationId/read',
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to mark notification as read'));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch<dynamic>(
        '/api/notifications/read-all',
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to mark all as read'));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete<dynamic>(
        '/api/notifications/$notificationId',
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to delete notification'));
    }
  }
}