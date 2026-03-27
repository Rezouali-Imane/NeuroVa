import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { LeaveRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const LeaveStudyRoom = async (data: LeaveRoomDTO) => {
    const room = await StudyRoomRepository.findById(data.roomid);
    if (!room) throw new Error("Room not found");

    const member = room.studyroommember.find(m => m.userid === data.userid);
    if (!member) throw new Error("User is not a member of this room");

    const wasOwner = member.isowner;

    const result = await StudyRoomRepository.leave(data);

    if (wasOwner) {
        await StudyRoomRepository.closeRoom(data.roomid);
    }

    return {
        success: true,
        userName: result.users.username,
        wasOwner: wasOwner
    };
};