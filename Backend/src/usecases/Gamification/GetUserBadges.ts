import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
export const GetUserBadges = async (userid: string) => {
    try {
        const badges = await GamificationRepository.GetAllBadgesByUser(userid);
        return {
            success: true,
            message: "Badges retrieved successfully",
            data: badges,
        };
    } catch (error) {
        return {
            success: false,
            message: "Failed to retrieve badges",
        };
    }
};