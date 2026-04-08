import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const GetXPHistory = async (userid: string) => {
    try {
        const xpHistory = await GamificationRepository.GetXPHistory(userid);
        return {
            success: true,
            message: "XP history retrieved successfully",
            data: xpHistory,
        };
    } catch (error) {
        console.error("Error retrieving XP history:", error);
        return {
            success: false,
            message: "Failed to retrieve XP history",
        };
    }
}   