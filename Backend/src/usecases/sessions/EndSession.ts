import { FocusSessionRepository } from "../../interfaces/repositories/FocusSessionRepository.js";
import { CalculateFocusScore } from "../../usecases/Gamification/CalculateFocusScore.js";

export const EndSession = async (sessionid: string) => {
  const session = await FocusSessionRepository.findById(sessionid);
  if (!session) {
    throw new Error("Session not found");
  }

  const now = new Date();

  await FocusSessionRepository.endSessionWithTimer(sessionid);

  if (session.starttime) {
    const durationMinutes = (now.getTime() - session.starttime.getTime()) / (1000 * 60);
    const focusMinutes = Math.max(0, durationMinutes - (session.allowbreakminutes || 0));
    await CalculateFocusScore({
      sessionid,
      focusminutes: focusMinutes,
      breakminutes: session.allowbreakminutes || 0,
      taskscompleted: 0,
    });
  }

  return await FocusSessionRepository.findById(sessionid);
};