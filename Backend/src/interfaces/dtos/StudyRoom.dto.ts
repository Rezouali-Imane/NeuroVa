
export interface CreateRoomDTO {
    roomname: string;
    ownerid: string; 
    ispublic?: boolean;   
   
}


export interface JoinRoomDTO {
    roomcode: string;
    userid: string;
}

export interface LeaveRoomDTO {
    roomid: string;
    userid: string;
}

export interface StartGroupSessionDTO {
    roomid: string;
    userid: string;
}

export interface EndGroupSessionDTO {
    roomid: string;
    userid: string;
    duration?: number;
}