import type { SessionStatus } from "../../entities/FocusSession.js";

export interface CreateFocusSessionDTO {
    userid: string;
    scheduleid?: string | null;
    roomid?: string | null;
    starttime: Date;
    endtime: Date;
    allowbreakminutes?: number;
    focusscore?: number;
    status?: SessionStatus;
}

export interface UpdateFocusSessionDTO {
    scheduleid?: string | null;
    roomid?: string | null;
    starttime?: Date;
    endtime?: Date;
    allowbreakminutes?: number;
    focusscore?: number;
    status?: SessionStatus;
}