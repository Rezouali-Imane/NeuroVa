import { NotificationType } from "../../entities/Notification.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import { NotificationService } from "../Notification/NotificationService.js";

export const AssignDailyChallenge = async (userid: string, templateid: string) => {
    const activeChallenge = await GamificationRepository.getActiveChallengesByUser(userid);
    const alreadyAssigned = activeChallenge.some((challenge) => challenge.templateid === templateid);

    if (alreadyAssigned) {
        return { success: false, message: "Challenge already assigned" };
    }

    const template = await GamificationRepository.getChallengeTemplateById(templateid);

    if (!template) {
        return { success: false, message: "Challenge template not found" };
    }

    const expiresat = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await GamificationRepository.createDailyChallenge({ userid, templateid, expiresat });

    const notificationSettings = await NotificationService.getSettings(userid);
    if (!notificationSettings || notificationSettings.dailychallengealerts !== false) {
        await NotificationService.scheduleNotification(userid, {
            type: NotificationType.DAILY_CHALLENGE,
            title: "New Daily Challenge Available",
            message: `A new challenge is ready: ${template.title}. Earn ${template.xpreward} XP.`,
        });
    }

    return { success: true, message: "Daily challenge assigned" };
};