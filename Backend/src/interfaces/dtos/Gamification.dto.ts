import { XPSource } from "../../entities/Gamification.entities.js";


export interface AwardXPDTO {
  userid: string;
  amount: number;
  source: XPSource;
  description?: string;
}

export interface AwardBadgeDTO {
  userid: string;
  name: string;
  description?: string;
  iconurl?: string;
  condition?: string;
}

export interface AwardAchievementDTO {
  userid: string;
  title: string;
  description?: string;
  pointsreward: number;
}

export interface AssignDailyChallengeDTO {
  userid: string;
  templateid: string;
  expiresat: Date;
}

export interface getDailyChallengeDTO {
  challengeid: string;
}

export interface GetLeaderboardDTO {
  leaderboardid: string;
  limit?: number;
}
export interface updateLeaderboardDTO {
  leaderboardid: string;
  userid: string;
  xppoints: number;
}

export interface updateStreakDTO {
  userid: string;
  bonusxp: number;
}

export interface GamificationResponseDTO {
  success: boolean;
  message: string;
}
