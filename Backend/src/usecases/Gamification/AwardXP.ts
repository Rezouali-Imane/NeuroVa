import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import type { AwardXPDTO } from "../../interfaces/dtos/Gamification.dto.js";

export const AwardXP = async (dto: AwardXPDTO) => {
    await GamificationRepository.createXPTransaction(dto);
    await GamificationRepository.incrementUserXP(dto.userid, dto.amount);
};