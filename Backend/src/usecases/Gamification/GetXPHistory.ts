import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const GetXPHistory = async (userid: string) => {
    try {
        const xpHistory = await GamificationRepository.getXPHistory(userid);
        return {
            success: true,
            message: "XP history retrieved successfully",
            data: xpHistory,
        };
    } catch (error) {
        return {
            success: false,
            message: error instanceof Error ? error.message : "Failed to retrieve XP history",
        };
    }
};