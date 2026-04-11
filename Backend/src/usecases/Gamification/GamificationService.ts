import type {
  AwardAchievementDTO,
  AwardBadgeDTO,
  AwardXPDTO,
  GetLeaderboardDTO,
  getDailyChallengeDTO,
  updateLeaderboardDTO,
} from "../../interfaces/dtos/Gamification.dto.js";
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
  static async awardXP(data: AwardXPDTO) {
    return AwardXP(data);
  }

  static async checkAndAwardAchievements(data: AwardAchievementDTO) {
    return CheckAndAwardAchievement(data);
  }

  static async awardBadge(data: AwardBadgeDTO) {
    return AwardBadge(data);
  }

  static async updateLeaderboard(data: updateLeaderboardDTO) {
    return UpdateLeaderboard(data);
  }

  static async assignDailyChallenge(userid: string, templateid: string) {
    return AssignDailyChallenge(userid, templateid);
  }

  static async completeChallenge(data: getDailyChallengeDTO) {
    return CompleteChallenge(data);
  }

  static async calculateStreak(userid: string) {
    return CalculateStreak(userid);
  }

  static async getLeaderboardTopN(data: GetLeaderboardDTO) {
    return GetLeaderboardTopN(data);
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
    sessionid: string;
    focusminutes: number;
    breakminutes: number;
    taskscompleted: number;
  }) {
    return CalculateFocusScore(data);
  }
}
