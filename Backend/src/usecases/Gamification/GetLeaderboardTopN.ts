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
        console.error("Error retrieving leaderboard:", error);
        return {
            success: false,
            message: error.message,
        };
    }
}