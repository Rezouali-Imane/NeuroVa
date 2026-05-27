import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { EndGroupSessionDTO } from "../../interfaces/dtos/StudyRoom.dto.js";
import { CalculateFocusScore } from "../Gamification/CalculateFocusScore.js";

export const EndGroupSession = async (data: EndGroupSessionDTO) => {
  const room = await StudyRoomRepository.findById(data.roomid);
  if (!room) throw new Error("Room not found.");
  if (!room.isactive) throw new Error("No active session to end");

  const owner = room.studyroommember.find(m => m.userid === data.userid && m.isowner);
  if (!owner) throw new Error("Only the room owner can end the session.");

  const activeSessions = room.focussession?.filter(s => s.status === "ACTIVE") || [];
  for (const session of activeSessions) {
    if (session.starttime) {
      const now = new Date();
      const durationMinutes = (now.getTime() - session.starttime.getTime()) / (1000 * 60);
      const focusMinutes = Math.max(0, durationMinutes - (session.allowbreakminutes || 0));
      await CalculateFocusScore({
        userid: data.userid,
        sessionid: session.sessionid,
        focusminutes: focusMinutes,
        breakminutes: session.allowbreakminutes || 0,
        taskscompleted: 0,
      });
    }
  }

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