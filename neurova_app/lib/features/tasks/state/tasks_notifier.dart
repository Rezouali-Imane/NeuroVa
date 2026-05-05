import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/tasks_service.dart';
import '../models/task_model.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../../../core/constants/app_constants.dart';
import '../services/google_calendar_service.dart';
import 'package:flutter/foundation.dart';

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final tasksServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return TasksService(dio, localStorage);
});

final googleCalendarServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return GoogleCalendarService(dio, localStorage);
});

class TasksNotifier extends StateNotifier<TasksState> {
  final TasksService _tasksService;
  final GoogleCalendarService _calendarService;
  final Ref _ref;

  TasksNotifier(this._tasksService, this._calendarService, this._ref)
      : super(TasksState());

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localStorage = _ref.read(localStorageServiceProvider);
      final userId = (await localStorage.readUserId()) ?? 'user';
      final tasks = await _tasksService.getTasks(userId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTask({
    required String userId,
    required String title,
    required String listId,
    String? description,
    DateTime? deadline,
    int priority = 1,
    String status = 'PENDING',
    String category = 'OTHER',
    bool syncWithGoogle = false,
  }) async {
    try {
      final task = await _tasksService.createTask(
        userId: userId,
        title: title,
        listId: listId,
        description: description,
        deadline: deadline,
        priority: priority,
        status: status,
        category: category,
      );
      state = state.copyWith(tasks: [...state.tasks, task]);

      if (syncWithGoogle) {
        await syncTaskToGoogle(task.taskid);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> syncTaskToGoogle(String taskId) async {
    try {
      await _calendarService.syncTaskToGoogle(taskId);
    } catch (e) {
      assert(() { debugPrint('Google sync failed: $e'); return true; }());
    }
  }

  Future<void> connectGoogleCalendar() async {
    try {
      await _calendarService.connectGoogleCalendar();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fullGoogleSync(String listId) async {
    try {
      await _calendarService.fullSync(listId);
      await fetchTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> disconnectGoogleCalendar() async {
    try {
      await _calendarService.disconnectGoogleCalendar();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final task = await _tasksService.updateTaskStatus(
        taskId: taskId,
        status: status,
      );
      final updatedTasks = state.tasks
          .map((t) => t.taskid == taskId ? task : t)
          .toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksService.deleteTask(taskId);
      state = state.copyWith(
          tasks: state.tasks.where((t) => t.taskid != taskId).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final tasksNotifierProvider =
StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final tasksService = ref.watch(tasksServiceProvider);
  final calendarService = ref.watch(googleCalendarServiceProvider);
  return TasksNotifier(tasksService, calendarService, ref);
});