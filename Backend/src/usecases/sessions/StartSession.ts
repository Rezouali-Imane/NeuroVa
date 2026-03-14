import { FocusSessionRepository } from "../../interfaces/repositories/FocusSessionRepository.js";
import { SessionStatus } from "../../entities/FocusSession.js";

export const StartSession = async (sessionid: string) => {
  const session = await FocusSessionRepository.findById(sessionid);
  if (!session) {
    throw new Error("Session not found");
  }
  return await FocusSessionRepository.update(sessionid, {
    starttime: new Date(),
    status: SessionStatus.ACTIVE,
  });
};
