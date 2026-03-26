import type { StudyRoomMember } from "./StudyRoomMember.js";

export interface StudyRoom {
    roomid: string;
    roomname: string;
    sessionduration: number;
    isactive: boolean;
    createdat: Date;
    studyroommember?: StudyRoomMember[]; 
}