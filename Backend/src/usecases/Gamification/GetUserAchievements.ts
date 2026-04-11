import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const GetUserAchievements = async (userid: string) => {
    try {
        const achievements = await GamificationRepository.getAllAchievementsByUser(userid);
        return {
            success: true,
            message: "Achievements retrieved successfully",
            data: achievements,
        };
    }catch (error) {
        return {
            success: false,
            message: error instanceof Error ? error.message : "Failed to retrieve achievements",
        };
    }
};