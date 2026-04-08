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

