
export interface CreateRoomDTO {
    roomname: string;
    sessionduration: number;
    ownerid: string;    
    // for FocusSession
    starttime: Date;
    endtime: Date;
}


export interface JoinRoomDTO {
    roomid: string;
    userid: string;
}

export interface SendMessageDTO {
    roomid: string;
    content: string;
}


export interface LeaveRoomDTO {
    roomid: string;
    userid: string;
}