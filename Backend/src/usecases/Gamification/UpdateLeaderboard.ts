import type { updateLeaderboardDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const UpdateLeaderboard = async (data: updateLeaderboardDTO) => {
    try {
        const updatedEntry = await GamificationRepository.upsertLeaderboardEntry(data);
        return {
            success: true,
            message: "Leaderboard updated successfully",
            data: updatedEntry,
        };
    } catch (error) {
        console.error("Error updating leaderboard:", error);
        return {
            success: false,
            message: "Failed to update leaderboard",
        };
    }
};