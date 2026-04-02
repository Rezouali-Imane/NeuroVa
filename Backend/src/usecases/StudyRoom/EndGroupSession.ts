import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { EndGroupSessionDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const EndGroupSession = async  (data: EndGroupSessionDTO) => {
    const room = await StudyRoomRepository.findById(data.roomid);

    if(!room) throw new Error("Room not found.");

    if (!room.isactive) throw new Error("No active session to end");

    const owner = room.studyroommember.find(
        (m) => m.userid === data.userid && m.isowner
    );
    if (!owner) throw new Error("Only tge room owner can end the session.");

    await StudyRoomRepository.closeRoom(data.roomid);

    return {
        success: true,
        message: "Group session ended. Room is now closed.",
        roomid: data.roomid,
        endedat: new Date(),
    };
};