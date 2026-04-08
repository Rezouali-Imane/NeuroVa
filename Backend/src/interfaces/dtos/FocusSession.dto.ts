import type { SessionStatus } from "../../entities/FocusSession.js";

export interface CreateFocusSessionDTO {
    userid: string;
    scheduleid?: string | null;
    roomid?: string | null;
    starttime: Date;
    focusscore: number;
    allowbreakminutes?: number;
    status?: SessionStatus;
}

export interface UpdateFocusSessionDTO {
    sessionid: string;
    starttime?: Date;
    endtime?: Date;
    allowbreakminutes?: number;
    focusscore?: number;
    status?: SessionStatus;
}

export interface CalculateFocusScoreDTO {
    sessionid: string;
    focusscore: number;
}