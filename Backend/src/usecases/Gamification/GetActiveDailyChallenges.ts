import {GamificationRepository} from "../../interfaces/repositories/GamificationRepository.js";

export const GetActiveDailyChallenges = async (userid: string) => {
    try {
        const dailyChallenges = await GamificationRepository.getAllChallengesByUser(userid);
        return {
            success: true,
            message: "Daily challenges retrieved successfully",
            data: dailyChallenges,
        };
    } catch (error) {

        return {
            success: false,
            message: error instanceof Error ? error.message : "Failed to retrieve daily challenges",
        };
    }
};