import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

export const CalculateStreak = async (userid: string) => {
    const lastSession = await GamificationRepository.getLastCompletedSession(userid);

    if (!lastSession || !lastSession.endtime) {
        await GamificationRepository.updateStreak(userid, 0);
        return { success: true, message: "No completed session found, streak reset", streak: 0 };
    }

    const lastSessionDate = new Date(lastSession.endtime);
    lastSessionDate.setHours(0, 0, 0, 0);

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const diffDays = (today.getTime() - lastSessionDate.getTime()) / (1000 * 60 * 60 * 24);

    const currentStreak = await GamificationRepository.getCurrentStreak(userid);

    let newStreak: number;

    if (diffDays === 0 || diffDays === 1) {
        newStreak = currentStreak + 1;
    } else {
        newStreak = 1;
    }

    await GamificationRepository.updateStreak(userid, newStreak);

    return { success: true, message: "Streak updated", streak: newStreak };
};