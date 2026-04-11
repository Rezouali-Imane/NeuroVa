import type { GetLeaderboardDTO} from "../../interfaces/dtos/Gamification.dto.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const GetLeaderboardTopN = async (data: GetLeaderboardDTO) => {
    try {
        const leaderboard = await GamificationRepository.getLeaderboardTopN(data);
        return {
            success: true,
            message: "Leaderboard retrieved successfully",
            data: leaderboard,
        };
    } catch (error) {
        return {
            success: false,
            message: error instanceof Error ? error.message : "Failed to retrieve leaderboard",
        };
    }
};