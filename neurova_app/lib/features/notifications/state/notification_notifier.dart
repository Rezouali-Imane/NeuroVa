import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../../../core/constants/app_constants.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final Map<String, dynamic>? settings;
  final bool isLoading;
  final String? error;

  int get unreadCount => notifications.where((n) => !n.isread).length;

  NotificationState({
    this.notifications = const [],
    this.settings,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    Map<String, dynamic>? settings,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final notificationServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return NotificationService(dio, localStorage);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(NotificationState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _service.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      // update the local list without refetching
      final updated = state.notifications.map((n) {
        return n.notificationid == notificationId
            ? NotificationModel(
          notificationid: n.notificationid,
          userid: n.userid,
          title: n.title,
          message: n.message,
          type: n.type,
          isread: true, // mark as read locally
          createdat: n.createdat,
        )
            : n;
      }).toList();
      state = state.copyWith(notifications: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      final updated = state.notifications.map((n) {
        return NotificationModel(
          notificationid: n.notificationid,
          userid: n.userid,
          title: n.title,
          message: n.message,
          type: n.type,
          isread: true,
          createdat: n.createdat,
        );
      }).toList();
      state = state.copyWith(notifications: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      state = state.copyWith(
        notifications: state.notifications
            .where((n) => n.notificationid != notificationId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final notification = await _service.createNotification(
        title: title,
        message: message,
        type: type,
      );
      state = state.copyWith(
        notifications: [notification, ...state.notifications],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchNotificationSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _service.getNotificationSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateNotificationSettings(
    Map<String, dynamic> newSettings,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.updateNotificationSettings(newSettings);
      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendEmailNotification({
    required String subject,
    required String message,
    required String type,
  }) async {
    try {
      await _service.sendEmailNotification(
        subject: subject,
        message: message,
        type: type,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendPushNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _service.sendPushNotification(
        title: title,
        message: message,
        type: type,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationNotifierProvider =
StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});