import { FocusSessionRepository } from "../../interfaces/repositories/FocusSessionRepository.js";
import type { CalculateFocusScoreDTO } from "../../interfaces/dtos/FocusSession.dto.js";

export const CalculateFocusScore = async (
  calculateFocusScoreData: CalculateFocusScoreDTO,
) => {
  const session = await FocusSessionRepository.findById(
    calculateFocusScoreData.sessionid,
  );
  if (!session) {
    throw new Error("Focus session not found");
  }
  const endtime = session.endtime || new Date();
  if (session.starttime == null) {
    throw new Error("Focus session start time not found");
  }
  const durationMinutes =
    (endtime.getTime() - session.starttime.getTime()) / (1000 * 60);
  const effectiveFocusMinutes = Math.max(
    0,
    durationMinutes - (session.allowbreakminutes || 0),
  );
  calculateFocusScoreData.focusscore = Math.round(effectiveFocusMinutes);
  return await FocusSessionRepository.calculateFocusScore(
    calculateFocusScoreData,
  );
};
