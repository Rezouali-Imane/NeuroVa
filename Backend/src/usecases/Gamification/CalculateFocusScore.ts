import { XPSource } from "../../entities/Gamification.entities.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import { AwardXP } from "./AwardXP.js";

interface CalculateFocusScoreDTO {
    userid: string;
    sessionid: string;
    focusminutes: number;
    breakminutes: number;
    taskscompleted: number;
}

export const CalculateFocusScore = async (dto: CalculateFocusScoreDTO) => {
    const { userid, sessionid, focusminutes, breakminutes, taskscompleted } = dto;

    const baseScore = focusminutes * 1.0;
    const breakPenalty = breakminutes * 0.5;
    const taskBonus = taskscompleted * 5;

    const score = Math.max(0, baseScore - breakPenalty + taskBonus);
    const rounded = Math.round(score * 100) / 100;

    await GamificationRepository.updateFocusScore(sessionid, rounded);

    const xpAmount = Math.round(score);
    if (xpAmount > 0) {
        await AwardXP({
            userid,
            amount: xpAmount,
            source: XPSource.SESSION_COMPLETED,
            description: `Focus score: ${rounded} from session ${sessionid}`,
        });
    }

    return { success: true, message: "Focus score calculated", score: rounded, xpAwarded: xpAmount };
};