import type {
  GetLeaderboardDTO,
} from "../../interfaces/dtos/Gamification.dto.js";
import { XPSource } from "../../entities/Gamification.entities.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import { AssignDailyChallenge } from "./AssignDailyChallenge.js";
import { AwardBadge } from "./AwardBadge.js";
import { AwardXP } from "./AwardXP.js";
import { CalculateFocusScore } from "./CalculateFocusScore.js";
import { CalculateStreak } from "./CalculateStreak.js";
import { CheckAndAwardAchievement } from "./CheckAndAwardAchievement.js";
import { CompleteChallenge } from "./CompleteChallenge.js";
import { GetActiveDailyChallenges } from "./GetActiveDailyChallenges.js";
import { GetLeaderboardTopN } from "./GetLeaderboardTopN.js";
import { GetUserAchievements } from "./GetUserAchievements.js";
import { GetUserBadges } from "./GetUserBadges.js";
import { GetXPHistory } from "./GetXPHistory.js";
import { UpdateLeaderboard } from "./UpdateLeaderboard.js";

export class GamificationService {
  // Diagram signature: awardXP(userId, amount, source)
  static async awardXP(
    userid: string,
    amount: number,
    source: XPSource,
    description?: string,
  ) {
    return AwardXP({ userid, amount, source, ...(description != null ? { description } : {}) });
  }

  // Diagram signature: checkAndAwardAchievements(userId)
  static async checkAndAwardAchievements(userid: string) {
    const streakState = await CalculateStreak(userid);
    if (!streakState.success) {
      return { success: false, message: "Could not evaluate achievements." };
    }

    const streak = typeof streakState.streak === "number" ? streakState.streak : 0;
    if (streak < 7) {
      return { success: true, message: "No new achievements yet." };
    }

    return CheckAndAwardAchievement({
      userid,
      title: "7-Day Focus Streak",
      description: "Maintained focus streak for 7 consecutive days.",
      pointsreward: 100,
    });
  }

  // Diagram signature: awardBadge(userId, badgeId)
  static async awardBadge(userid: string, badgeId: string) {
    return AwardBadge({
      userid,
      name: badgeId,
      condition: `badge:${badgeId}`,
    });
  }

  // Diagram signature: updateLeaderboard()
  static async updateLeaderboard() {
    const leaderboards = await GamificationRepository.getAllLeaderboards();
    await Promise.all(
      leaderboards.map((lb) =>
        GamificationRepository.updateRanks({ leaderboardid: lb.leaderboardid }),
      ),
    );
    return { success: true, message: "Leaderboard rankings refreshed." };
  }

  // Backward-compatible targeted leaderboard update.
  static async updateLeaderboardEntry(data: {
    leaderboardid: string;
    userid: string;
    xppoints: number;
  }) {
    return UpdateLeaderboard(data);
  }

  // Diagram signature: assignDailyChallenge(userId)
  static async assignDailyChallenge(userid: string) {
    const template = await GamificationRepository.getFirstChallengeTemplate();
    if (!template) {
      return { success: false, message: "No challenge templates configured." };
    }
    return AssignDailyChallenge(userid, template.templateid);
  }

  // Diagram signature: completeChallenge(challengeId)
  static async completeChallenge(challengeid: string) {
    return CompleteChallenge({ challengeid });
  }

  static async calculateStreak(userid: string) {
    return CalculateStreak(userid);
  }

  // Diagram signature: getLeaderboardTopN(n)
  static async getLeaderboardTopN(n: number, leaderboardid: string) {
    return GetLeaderboardTopN({ leaderboardid, limit: n } as GetLeaderboardDTO);
  }

  static async getXPHistory(userid: string) {
    return GetXPHistory(userid);
  }

  static async getUserAchievements(userid: string) {
    return GetUserAchievements(userid);
  }

  static async getUserBadges(userid: string) {
    return GetUserBadges(userid);
  }

  static async getActiveDailyChallenges(userid: string) {
    return GetActiveDailyChallenges(userid);
  }

  static async calculateFocusScore(data: {
    userid: string;
    sessionid: string;
    focusminutes: number;
    breakminutes: number;
    taskscompleted: number;
  }) {
    return CalculateFocusScore(data);
  }
}
