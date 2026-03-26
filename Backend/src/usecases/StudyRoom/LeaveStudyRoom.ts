import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { LeaveRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const LeaveStudyRoom = async (data: LeaveRoomDTO) => {
  
    const room = await StudyRoomRepository.findById(data.roomid);
    
    if (!room) {
        throw new Error("This study room no longer exists.");
    }

    // Identify the member who is leaving
    const member = room.studyroommember.find(m => m.userid === data.userid);
    
    if (!member) {
        throw new Error("User is not a member of this room.");
    }

   
    // it will be used on the controler meaning that the owner left the session and the session is closed
    const isOwner = member.isowner;

    const result = await StudyRoomRepository.leave(data);

    return {
        success: true,
        wasOwner: isOwner,
        data: result
    };
};