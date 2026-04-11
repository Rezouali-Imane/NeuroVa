import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const AssignDailyChallenge = async (userid: string, templateid: string) => {
    const activeChallenge = await GamificationRepository.findActiveChallengeByUserId(userid);

    if (activeChallenge) {
        return { success: false, message: "User already has an active challenge" };
    }

    const template = await GamificationRepository.getChallengeTemplateById(templateid);

    if (!template) {
        return { success: false, message: "Challenge template not found" };
    }

    const expiresat = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await GamificationRepository.createDailyChallenge({ userid, templateid, expiresat });

    return { success: true, message: "Daily challenge assigned" };
};