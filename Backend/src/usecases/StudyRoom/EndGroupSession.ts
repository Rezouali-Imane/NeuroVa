import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { EndGroupSessionDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const EndGroupSession = async (data: EndGroupSessionDTO) => {
  const room = await StudyRoomRepository.findById(data.roomid);
  if (!room) throw new Error("Room not found.");
  if (!room.isactive) throw new Error("No active session to end");

  const owner = room.studyroommember.find(m => m.userid === data.userid && m.isowner);
  if (!owner) throw new Error("Only the room owner can end the session.");

  await StudyRoomRepository.completeAllFocusSessions(data.roomid);
  await StudyRoomRepository.closeRoom(data.roomid);
  
  if (data.duration !== undefined) {
    await StudyRoomRepository.updateRoomDuration(data.roomid, data.duration);
  }

  return {
    success: true,
    message: "Group session ended. Room is now closed.",
    roomid: data.roomid,
    endedat: new Date(),
  };
};