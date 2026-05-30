import 'package:dio/dio.dart';
import '../../../shared/services/local_storage_service.dart';
import '../models/gamification_models.dart';

class GamificationService {
  final Dio _dio;
  final LocalStorageService _localStorage;

  GamificationService(this._dio, this._localStorage);

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

  Future<List<XpEntry>> getXpHistory() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/gamification/xp-history',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data.map((e) => XpEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch XP history'));
    }
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/gamification/achievements',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch achievements'));
    }
  }

  Future<List<Badge>> getBadges() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/gamification/badges',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data.map((e) => Badge.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch badges'));
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard(String leaderboardId, {int limit = 10}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/gamification/leaderboard/$leaderboardId/top/$limit',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch leaderboard'));
    }
  }

  Future<List<DailyChallenge>> getActiveChallenges() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/gamification/daily-challenges/active',
        options: await _options(),
      );
      final List data = response.data['data'] as List;
      return data.map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception(_readError(e, 'Failed to fetch daily challenges'));
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/daily-challenges/complete/$challengeId',
        options: await _options(),
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        final msg = data != null && data['message'] != null ? data['message'] as String : 'Failed to complete challenge';
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception(_readError(e, 'Failed to complete challenge'));
    }
  }

  Future<int> calculateStreak() async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/streak/calculate',
        options: await _options(),
      );
      return (response.data['streak'] as int?) ?? 0;
    } catch (e) {
      throw Exception(_readError(e, 'Failed to calculate streak'));
    }
  }

  Future<Map<String, dynamic>> calculateFocusScore({
    required String sessionId,
    required int focusMinutes,
    required int breakMinutes,
    required int tasksCompleted,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/focus-score/calculate',
        data: {
          'sessionid': sessionId,
          'focusminutes': focusMinutes,
          'breakminutes': breakMinutes,
          'taskscompleted': tasksCompleted,
        },
        options: await _options(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_readError(e, 'Failed to calculate focus score'));
    }
  }

  Future<void> awardXP({
    required int amount,
    required String source,
    String? description,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/api/gamification/xp/award',
        data: {
          'amount': amount,
          'source': source,
          'description': description,
        },
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to award XP'));
    }
  }

  Future<Map<String, dynamic>> checkAndAwardAchievement() async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/achievements/check-and-award',
        options: await _options(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_readError(e, 'Failed to check and award achievement'));
    }
  }

  Future<Map<String, dynamic>> awardBadge(String badgeId) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/badges/award',
        data: {'badgeid': badgeId},
        options: await _options(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_readError(e, 'Failed to award badge'));
    }
  }

  Future<void> updateLeaderboard({
    required String leaderboardId,
    required int xpPoints,
  }) async {
    try {
      await _dio.post<dynamic>(
        '/api/gamification/leaderboard/update',
        data: {
          'leaderboardid': leaderboardId,
          'xppoints': xpPoints,
        },
        options: await _options(),
      );
    } catch (e) {
      throw Exception(_readError(e, 'Failed to update leaderboard'));
    }
  }

  Future<Map<String, dynamic>> assignDailyChallenge() async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/gamification/daily-challenges/assign',
        options: await _options(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception(_readError(e, 'Failed to assign daily challenge'));
    }
  }
}