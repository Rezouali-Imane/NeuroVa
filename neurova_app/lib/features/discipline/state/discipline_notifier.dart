// ignore_for_file: unused_import

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/discipline_model.dart';
import '../services/discipline_service.dart';
import 'package:dio/dio.dart';

final disciplineServiceProvider = Provider<DisciplineService>((ref) {
  final dio = Dio();
  return DisciplineService(dio);
});

final disciplineNotifierProvider = StateNotifierProvider.family<
    DisciplineNotifier,
    AsyncValue<Map<String, dynamic>>,
    String>((ref, userId) {
  final service = ref.watch(disciplineServiceProvider);
  return DisciplineNotifier(service, userId);
});

class DisciplineNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final DisciplineService _service;
  final String _userId;

  DisciplineNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _loadData() async {
    try {
      // Parallelize all API calls instead of sequential awaits
      final results = await Future.wait([
        _service.getSettings(_userId),
        _service.getTodayUsage(_userId),
        _service.calculateScore(_userId),
      ]);

      state = AsyncValue.data({
        'settings': results[0],
        'usageLogs': results[1],
        'score': results[2],
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(DisciplineSettings settings) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateSettings(_userId, settings);
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshData() async {
    try {
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBlockedApp(String appName, String appUrl) async {
    try {
      final app = BlockedApp(
        appId: const Uuid().v4(),
        appName: appName,
        packageName: appUrl,
        isBlocked: true,
      );
      await _service.addBlockedApp(_userId, app);
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBlockedWebsite(String domain, String websiteName) async {
    try {
      final website = BlockedWebsite(
        websiteId: const Uuid().v4(),
        domain: domain,
        category: websiteName,
        isBlocked: true,
      );
      await _service.addBlockedWebsite(_userId, website);
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSchedule(String label, String timeRange) async {
    try {
      // Parse the time range and create schedule
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
