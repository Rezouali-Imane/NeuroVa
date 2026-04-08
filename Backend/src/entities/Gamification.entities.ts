export interface achivement {
    achivementid: string;
    userid: string;
    title: string;
    description?: string;
    pointsreward: number;
    earneDate: Date;
}

export interface Badge {
    badgeid: string;
    userid: string;
    name: string;
    description?: string;
    iconurl?: string;
    condition: string;
    earnedDate: Date;
}

export interface xptransaction {
    transactionid: string;
    userid: string;
    amount: number;
    source: string;
    description?: string;
    createDate: Date;
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
    recordDate: Date;
}

export interface dailychallenge {
    challengeid: string;
    userid: string;
    templateid: string;
    iscompleted: boolean;
    assigndate: Date;
    completedate: Date;
    expiresat: Date;
}

export interface ChallengeTemplate {
    templateid: string;
    title: string;
    description?: string;
    pointsreward: number;
    condition: string;
}

