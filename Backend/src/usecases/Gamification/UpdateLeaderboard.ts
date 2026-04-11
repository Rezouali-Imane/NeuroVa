import type { updateLeaderboardDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const UpdateLeaderboard = async (data: updateLeaderboardDTO) => {
   await GamificationRepository.upsertLeaderboardEntry(data);
   await GamificationRepository.updateRanks({
       leaderboardid: data.leaderboardid,
   });

   return {
       success: true,
       message: "Leaderboard successfully updated",
   };
};