import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { StartGroupSessionDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const StartGroupSession = async  (data: StartGroupSessionDTO) => {
    const room = await StudyRoomRepository.findById(data.roomid);

    if(!room) throw new Error("Room not found.");

    if (room.isactive) throw new Error("Session is already active.");

    const owner = room.studyroommember.find(
        (m) => m.userid === data.userid && m.isowner
    );
    if (!owner) throw new Error("Only tge room owner can start the session.");

    await StudyRoomRepository.startSession(data.roomid);

    return {
        success: true,
        message: "Group session started.",
        roomid: data.roomid,
        startedat: new Date(),
    };
};