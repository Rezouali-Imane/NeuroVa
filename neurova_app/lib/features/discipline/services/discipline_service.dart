import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/discipline_model.dart';

class DisciplineService {
  final Dio _dio;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  DisciplineService(this._dio);

  Future<DisciplineSettings> getSettings(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/discipline/$userId/settings');
      if (response.statusCode == 200) {
        return DisciplineSettings.fromJson(response.data);
      }
      throw Exception('Failed to get discipline settings');
    } catch (e) {
      debugPrint('[DisciplineService] Error getting settings: $e');
      rethrow;
    }
  }

  Future<void> updateSettings(String userId, DisciplineSettings settings) async {
    try {
      await _dio.put(
        '$_baseUrl/discipline/$userId/settings',
        data: settings.toJson(),
      );
    } catch (e) {
      debugPrint('[DisciplineService] Error updating settings: $e');
      rethrow;
    }
  }

  Future<List<BlockedApp>> getBlockedApps(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/discipline/$userId/blocked-apps');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((app) => BlockedApp.fromJson(app as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[DisciplineService] Error getting blocked apps: $e');
      return [];
    }
  }

  Future<void> addBlockedApp(String userId, BlockedApp app) async {
    try {
      await _dio.post(
        '$_baseUrl/discipline/$userId/blocked-apps',
        data: app.toJson(),
      );
    } catch (e) {
      debugPrint('[DisciplineService] Error adding blocked app: $e');
      rethrow;
    }
  }

  Future<void> removeBlockedApp(String userId, String appId) async {
    try {
      await _dio.delete('$_baseUrl/discipline/$userId/blocked-apps/$appId');
    } catch (e) {
      debugPrint('[DisciplineService] Error removing blocked app: $e');
      rethrow;
    }
  }

  Future<List<BlockedWebsite>> getBlockedWebsites(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/discipline/$userId/blocked-websites');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((site) => BlockedWebsite.fromJson(site as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[DisciplineService] Error getting blocked websites: $e');
      return [];
    }
  }

  Future<void> addBlockedWebsite(String userId, BlockedWebsite website) async {
    try {
      await _dio.post(
        '$_baseUrl/discipline/$userId/blocked-websites',
        data: website.toJson(),
      );
    } catch (e) {
      debugPrint('[DisciplineService] Error adding blocked website: $e');
      rethrow;
    }
  }

  Future<void> removeBlockedWebsite(String userId, String websiteId) async {
    try {
      await _dio.delete('$_baseUrl/discipline/$userId/blocked-websites/$websiteId');
    } catch (e) {
      debugPrint('[DisciplineService] Error removing blocked website: $e');
      rethrow;
    }
  }

  Future<List<UsageLog>> getTodayUsage(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/discipline/$userId/usage/today');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((log) => UsageLog.fromJson(log as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[DisciplineService] Error getting today usage: $e');
      return [];
    }
  }

  Future<void> logUsage(String userId, String appOrWebsite, int durationSeconds) async {
    try {
      await _dio.post(
        '$_baseUrl/discipline/$userId/usage/log',
        data: {
          'appOrWebsite': appOrWebsite,
          'duration': durationSeconds,
        },
      );
    } catch (e) {
      debugPrint('[DisciplineService] Error logging usage: $e');
      rethrow;
    }
  }

  Future<DisciplineScore> calculateScore(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/discipline/$userId/score');
      if (response.statusCode == 200) {
        return DisciplineScore.fromJson(response.data);
      }
      throw Exception('Failed to calculate score');
    } catch (e) {
      debugPrint('[DisciplineService] Error calculating score: $e');
      rethrow;
    }
  }
}
