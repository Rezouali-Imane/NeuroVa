import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { JoinRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const JoinStudyRoom = async (data: JoinRoomDTO) => {
  
    const room = await StudyRoomRepository.findById(data.roomid);
    
    if (!room) {
        throw new Error("This study room no longer exists.");
    }

    //  Check room capacity
    if (room.studyroommember.length >= 10) // limitigh ar 10 zar kunwi amk iknisu3edh
         { 
        throw new Error("This room is full.");
    }

   
    const alreadyMember = room.studyroommember.some(m => m.userid === data.userid);
    if (alreadyMember) {
        throw new Error("You are already in this room.");
    }

    //  Get the owner's session to check the timing
    const ownerMember = room.studyroommember.find(m => m.isowner);
    const ownerSession = room.focussession.find(s => s.userid === ownerMember?.userid);
    
    if (!ownerSession) {
        throw new Error("The session timing could not be synchronized.");
    }

    const now = new Date();
    if (now > ownerSession.starttime) {
        throw new Error("The session has already started. You cannot join a live focus session.");
    }
   
    const result = await StudyRoomRepository.join(data, ownerSession.starttime, ownerSession.endtime);

    return {
        success: true,
        message: "Joined the StudyRoom successfully.",
        roomData: room,
        newMember: result
    };
};