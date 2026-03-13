export enum SessionStatus {
    SCHEDULED = 'SCHEDULED',
    ACTIVE = 'ACTIVE',
    COMPLETED = 'COMPLETED',
    CANCELED = 'CANCELED',
}

export interface FocusSession {
    sessionid: string;
    userid: string;
    scheduleid?: string;
    roomid?: string;
    starttime: Date;
    endtime: Date;
    allowbreakminutes: number;
    focusscore: number;
    status: SessionStatus;
}