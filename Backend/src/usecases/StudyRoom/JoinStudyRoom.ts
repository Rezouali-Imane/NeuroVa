import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { JoinRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const JoinStudyRoom = async (data: JoinRoomDTO) => {
  const room = await StudyRoomRepository.findById(data.roomid);

  if (!room) {
    throw new Error("This study room no longer exists.");
  }

  if (room.studyroommember.length >= 10) {
    throw new Error("This room is full.");
  }

  const alreadyMember = room.studyroommember.some(
    (m) => m.userid === data.userid,
  );
  if (alreadyMember) {
    throw new Error("You are already in this room.");
  }

  if (room.isactive) {
    throw new Error(
      "The study session has already started and is locked for new members.",
    );
  }

  const ownerMember = room.studyroommember.find((m) => m.isowner);
  const ownerSession = room.focussession.find(
    (s) => s.userid === ownerMember?.userid,
  );

  if (!ownerSession) {
    throw new Error("The session timing could not be synchronized.");
  }

  const result = await StudyRoomRepository.join(
    data,
    ownerSession.starttime,
    ownerSession.endtime,
  );

  const updatedRoom = await StudyRoomRepository.findById(data.roomid);

  return {
    success: true,
    message: "Joined the StudyRoom successfully.",
    roomData: updatedRoom,
    userName: result.users.username,
    newMember: result,
  };
};
