import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

interface CalculateFocusScoreDTO {
    sessionid: string;
    focusminutes: number;
    breakminutes: number;
    taskscompleted: number;
}

export const CalculateFocusScore = async (dto: CalculateFocusScoreDTO) => {
    const { sessionid, focusminutes, breakminutes, taskscompleted } = dto;

    const baseScore = focusminutes * 1.0;
    const breakPenalty = breakminutes * 0.5;
    const taskBonus = taskscompleted * 5;

    const score = Math.max(0, baseScore - breakPenalty + taskBonus);
    const rounded = Math.round(score * 100) / 100;

    await GamificationRepository.updateFocusScore(sessionid, rounded);

    return { success: true, message: "Focus score calculated", score: rounded };
};