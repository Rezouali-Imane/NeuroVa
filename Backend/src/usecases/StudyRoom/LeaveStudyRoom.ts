import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { LeaveRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const LeaveStudyRoom = async (data: LeaveRoomDTO) => {
  const room = await StudyRoomRepository.findById(data.roomid);
  if (!room) throw new Error("Room not found");

  const member = room.studyroommember.find(m => m.userid === data.userid);
  if (!member) throw new Error("User is not a member of this room");

  const isOwner = member.isowner;

  await StudyRoomRepository.cancelFocusSession(data.roomid, data.userid);

  const result = await StudyRoomRepository.leave(data.roomid, data.userid);

  if (isOwner) {
    await StudyRoomRepository.closeRoom(data.roomid);
  }

  return {
    success: true,
    message: isOwner ? "Room closed by owner." : "Left the study room successfully!",
    username: result.users.username,
    isOwner,
  };
};