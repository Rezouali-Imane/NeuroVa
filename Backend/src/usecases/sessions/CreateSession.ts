import { FocusSessionRepository } from "../../interfaces/repositories/FocusSessionRepository.js";
import { SessionStatus } from "../../entities/FocusSession.js";
import type { CreateFocusSessionDTO } from "../../interfaces/dtos/FocusSession.dto.js";

export const CreateSession = async (data: CreateFocusSessionDTO) => {
  if (!data.userid) {
    throw new Error("User ID is required");
  }
  if (!data.starttime) {
    throw new Error("Start time is required");
  }


  if (data.allowbreakminutes !== undefined && data.allowbreakminutes < 0) {
    throw new Error("Break minutes cannot be negative");
  }

  return await FocusSessionRepository.create({
    userid: data.userid,
    scheduleid: data.scheduleid ?? null,
    roomid: data.roomid ?? null,
    starttime: data.starttime,
    allowbreakminutes: data.allowbreakminutes ?? 0,
    focusscore: 0,
    status: SessionStatus.SCHEDULED,
  });
};
