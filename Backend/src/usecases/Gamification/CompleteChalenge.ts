import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import  type{ getDailyChallengeDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { XPSource } from "../../entities/Gamification.entities.js";
export const CompleteChallenge = async (getDailyChallengeDTO: getDailyChallengeDTO) => {
const challenge = await GamificationRepository.completeDailyChallenge(getDailyChallengeDTO);
if (!challenge) {
    return {
        success: false,
        message: "Challenge not found or already completed",
    };  
}else {
    await GamificationRepository.CreatXPtransaction({
        userid: challenge.userid,
        amount: 100,
        source: XPSource.CHALLENGE_COMPLETED,
        description: "Completed daily challenge"
    });
    return {
        success: true,
        message: "Challenge completed and XP awarded successfully",
    };  
};
}