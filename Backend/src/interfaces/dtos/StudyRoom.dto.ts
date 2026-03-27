
export interface CreateRoomDTO {
    roomname: string;
    sessionduration: number;
    ownerid: string;    
   
}


export interface JoinRoomDTO {
    roomid: string;
    userid: string;
}

export interface SendMessageDTO {
    roomid: string;
    content: string;
    senderid: string;
}


export interface LeaveRoomDTO {
    roomid: string;
    userid: string;
}