export interface StudyRoomMember {
    memberid: string;
    userid: string;
    roomid: string;
    isowner: boolean;
    joinedat: Date;
    leftat?: Date | null;
}