import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import type { AwardXPDTO } from "../../interfaces/dtos/Gamification.dto.js";

export const AwardXP = async (dto: AwardXPDTO) => {
    await GamificationRepository.creatXPTransaction(dto);
    await GamificationRepository.incrementuserXP(dto.userid, dto.amount);
}