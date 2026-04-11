import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import type { AwardBadgeDTO } from "../../interfaces/dtos/Gamification.dto.js";

export const AwardBadge = async (dto: AwardBadgeDTO) => {
    const existing = await GamificationRepository.getBadgeByName(
        dto.name,
        dto.userid
    );

    if (existing.length > 0) {
        return { success: false, message: "Badge already awarded" };
    }

    await GamificationRepository.createBadge(dto);

    return { success: true, message: "Badge awarded" };
};