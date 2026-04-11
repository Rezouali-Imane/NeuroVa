import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import type { getDailyChallengeDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { XPSource } from "../../entities/Gamification.entities.js";
export const CompleteChallenge = async (
  getDailyChallengeDTO: getDailyChallengeDTO,
) => {
  const challenge =
    await GamificationRepository.findChallengeById(getDailyChallengeDTO);
  const date = new Date();
  if (!challenge) {
    return { success: false, message: "Challenge not found" };
  }

  if (challenge.iscompleted) {
    return { success: false, message: "Challenge already completed" };
  }
  if (challenge.expiresat < date) {
    return { success: false, message: "Challenge has expired" };
  }

  const completedchallenge =
    await GamificationRepository.completeDailyChallenge(getDailyChallengeDTO);
  
    if (!completedchallenge) {
    return { success: false, message: "Failed to complete challenge" };
  }

  await GamificationRepository.createXPTransaction({
    userid: completedchallenge.userid,
    amount: 100,
    source: XPSource.CHALLENGE_COMPLETED,
    description: "Completed daily challenge",
  });
  await GamificationRepository.incrementUserXP(completedchallenge.userid, 100);
  return {
    success: true,
    message: "Challenge completed and XP awarded successfully",
  };
};
