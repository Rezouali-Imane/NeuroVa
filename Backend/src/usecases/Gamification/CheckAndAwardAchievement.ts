import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import type { AwardAchievementDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { XPSource } from "../../entities/Gamification.entities.js";

export const CheckAndAwardAchievement = async (dto: AwardAchievementDTO) => {
    const existing = await GamificationRepository.getAchievementsByTitle(
        dto.title,
        dto.userid
    );

    if (existing.length > 0) {
        return { success: false, message: "Achievement already earned" };
    }

    await GamificationRepository.createAchievement(dto);

    await GamificationRepository.createXPTransaction({
        userid: dto.userid,
        amount: dto.pointsreward,
        source: XPSource.ACHIEVEMENT_EARNED,
        description: `Achievement unlocked: ${dto.title}`,
    });

    await GamificationRepository.incrementUserXP(dto.userid, dto.pointsreward);

    return { success: true, message: "Achievement awarded" };
};