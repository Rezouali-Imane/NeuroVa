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

export interface CompleteDailyChallengeDTO {
    challengeid: string;

}

export interface GetLeaderboardDTO {
  leaderboardid: string;
}
export interface updateLeaderboardDTO {
    leaderboardid: string; 
}

export interface GamificationResponseDTO {
    success: boolean;
    message: string;
}