import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';
import '../../auth/state/auth_notifier.dart' show localStorageServiceProvider;
import '../../../core/constants/app_constants.dart';

class GamificationState {
  final List<XpEntry> xpHistory;
  final List<Achievement> achievements;
  final List<Badge> badges;
  final List<LeaderboardEntry> leaderboard;
  final List<DailyChallenge> challenges;
  final int streak;
  final bool isLoading;
  final String? error;

  int get totalXp => xpHistory.fold(0, (sum, e) => sum + e.amount);

  GamificationState({
    this.xpHistory = const [],
    this.achievements = const [],
    this.badges = const [],
    this.leaderboard = const [],
    this.challenges = const [],
    this.streak = 0,
    this.isLoading = false,
    this.error,
  });

  GamificationState copyWith({
    List<XpEntry>? xpHistory,
    List<Achievement>? achievements,
    List<Badge>? badges,
    List<LeaderboardEntry>? leaderboard,
    List<DailyChallenge>? challenges,
    int? streak,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      xpHistory: xpHistory ?? this.xpHistory,
      achievements: achievements ?? this.achievements,
      badges: badges ?? this.badges,
      leaderboard: leaderboard ?? this.leaderboard,
      challenges: challenges ?? this.challenges,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final gamificationServiceProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  final localStorage = ref.watch(localStorageServiceProvider);
  return GamificationService(dio, localStorage);
});

class GamificationNotifier extends StateNotifier<GamificationState> {
  final GamificationService _service;

  GamificationNotifier(this._service) : super(GamificationState());

  Future<void> fetchAll(String leaderboardId) async {
    print('=== GamificationNotifier.fetchAll() called with leaderboardId: $leaderboardId ===');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch the main data that doesn't depend on user being fully set up
      final xpList = await _service.getXpHistory();
      final achievements = await _service.getAchievements();
      final badges = await _service.getBadges();
      final leaderboardList = await _service.getLeaderboard(leaderboardId);
      final challenges = await _service.getActiveChallenges();

      // Streak calculation may fail if user record isn't fully initialized; make it optional
      int streakData = 0;
      try {
        streakData = await _service.calculateStreak();
      } catch (streakError) {
        print('Warning: Streak calculation failed: $streakError. Continuing without streak.');
      }

      print('Fetched: XP=${xpList.length}, Achievements=${achievements.length}, Badges=${badges.length}, Leaderboard=${leaderboardList.length}, Challenges=${challenges.length}, Streak=$streakData');

      state = state.copyWith(
        xpHistory: xpList,
        achievements: achievements,
        badges: badges,
        leaderboard: leaderboardList,
        challenges: challenges,
        streak: streakData,
        isLoading: false,
      );
      print('=== fetchAll() completed successfully ===');
    } catch (e) {
      print('=== fetchAll() ERROR: $e ===');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    try {
      await _service.completeChallenge(challengeId);
      final updated = state.challenges.map((c) {
        return c.challengeid == challengeId
            ? DailyChallenge(
          challengeid: c.challengeid,
          title: c.title,
          description: c.description,
          iscompleted: true,
          xpreward: c.xpreward,
        )
            : c;
      }).toList();
      state = state.copyWith(challenges: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> calculateFocusScore({
    required String sessionId,
    required int focusMinutes,
    required int breakMinutes,
    required int tasksCompleted,
  }) async {
    try {
      await _service.calculateFocusScore(
        sessionId: sessionId,
        focusMinutes: focusMinutes,
        breakMinutes: breakMinutes,
        tasksCompleted: tasksCompleted,
      );
      final xpHistory = await _service.getXpHistory();
      state = state.copyWith(xpHistory: xpHistory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> awardXP({
    required int amount,
    required String source,
    String? description,
  }) async {
    try {
      await _service.awardXP(amount: amount, source: source, description: description);
      final xpHistory = await _service.getXpHistory();
      state = state.copyWith(xpHistory: xpHistory);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkAndAwardAchievement() async {
    try {
      await _service.checkAndAwardAchievement();
      final achievements = await _service.getAchievements();
      state = state.copyWith(achievements: achievements);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> awardBadge(String badgeId) async {
    try {
      await _service.awardBadge(badgeId);
      final badges = await _service.getBadges();
      state = state.copyWith(badges: badges);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateLeaderboard({
    required String leaderboardId,
    required int xpPoints,
  }) async {
    try {
      await _service.updateLeaderboard(leaderboardId: leaderboardId, xpPoints: xpPoints);
      final leaderboard = await _service.getLeaderboard(leaderboardId);
      state = state.copyWith(leaderboard: leaderboard);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> assignDailyChallenge() async {
    try {
      await _service.assignDailyChallenge();
      final challenges = await _service.getActiveChallenges();
      state = state.copyWith(challenges: challenges);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final gamificationNotifierProvider =
StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  final service = ref.watch(gamificationServiceProvider);
  return GamificationNotifier(service);
});