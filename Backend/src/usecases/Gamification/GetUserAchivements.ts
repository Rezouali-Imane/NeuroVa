import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const GetUserAchivements = async (userid: string) => {
    try {
        const achivements = await GamificationRepository.GetAllAchivementsByUser(userid);
        return {
            success: true,
            message: "Achivements retrieved successfully",
            data: achivements,
        };
}catch (error) {
        return {
            success: false,
            message: "Failed to retrieve achivements",
        };
    }
}