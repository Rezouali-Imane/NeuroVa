

export enum XPSource {
  TASK_COMPLETED = "TASK_COMPLETED",
  SESSION_COMPLETED = "SESSION_COMPLETED",
  STREAK_BONUS = "STREAK_BONUS",
  CHALLENGE_COMPLETED = "CHALLENGE_COMPLETED",
  ACHIEVEMENT_EARNED = "ACHIEVEMENT_EARNED",
  NOTE_CREATED = "NOTE_CREATED",
}


export interface Achievement {
    achievementid: string;
    userid: string;
    title: string;
    description?: string;
    pointsreward: number;
    earnedate: Date;
}

export interface Badge {
    badgeid: string;
    userid: string;
    name: string;
    description?: string;
    iconurl?: string;
    condition?: string;
    earnedate: Date;
}

export interface XPTransaction {
    transactionid: string;
    userid: string;
    amount: number;
    source: XPSource;
    description?: string;
    createdate: Date;
}

export interface Leaderboard {
    leaderboardid: string;
    lastupdated: Date;
    type: string;
    scope: string;
}
export interface LeaderboardEntry {
    entryid: string;
    leaderboardid: string;
    userid: string;
    rank: number;
    xppoints: number;
    recorddate: Date;
}

export interface DailyChallenge {
    challengeid: string;
    userid: string;
    templateid: string;
    iscompleted: boolean;
    assigndate: Date;
    completedate?: Date;
    expiresat: Date;
}

export interface ChallengeTemplate {
    templateid: string;
    title: string;
    description?: string;
    xpreward : number;
    createdate: Date;
}

