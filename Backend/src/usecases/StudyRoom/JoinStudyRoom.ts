import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { JoinRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const JoinStudyRoom = async (data: JoinRoomDTO) => {
  const room = await StudyRoomRepository.findByCode(data.roomcode);

  if (!room) {
    throw new Error("Room not found. Check the room code and try again.");
  }

  if (room.isactive) {
    throw new Error("Session already started. You cannot join at this time.");
  }

  // No duplicate check – the repository will handle reactivation
  const updatedRoom = await StudyRoomRepository.join(data, room.roomid);

  return {
    success: true,
    message: "Joined the Study Room successfully.",
    data: updatedRoom,
  };
};