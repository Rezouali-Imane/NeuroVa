import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";
import prisma from "../../infrastructure/database/prisma.client.js";
import type { getDailyChallengeDTO } from "../../interfaces/dtos/Gamification.dto.js";
import { XPSource } from "../../entities/Gamification.entities.js";
import { NotificationService } from "../Notification/NotificationService.js";
import { NotificationType } from "../../entities/Notification.js";
import { GetActiveDailyChallenges } from "./GetActiveDailyChallenges.js";
export const CompleteChallenge = async (
  getDailyChallengeDTO: getDailyChallengeDTO,
) => {
  const challenge =
    await GamificationRepository.findChallengeById(getDailyChallengeDTO);
  const date = new Date();
  if (!challenge) {
    return { success: false, message: "Challenge not found" };
  }

  if (challenge.iscompleted) {
    return { success: false, message: "Challenge already completed" };
  }
  if (challenge.expiresat < date) {
    return { success: false, message: "Challenge has expired" };
  }

  const completedchallenge =
    await GamificationRepository.completeDailyChallenge(getDailyChallengeDTO);
  
    if (!completedchallenge) {
    return { success: false, message: "Failed to complete challenge" };
  }

  const template = await GamificationRepository.getChallengeTemplateById(challenge.templateid);
  const xpReward = template?.xpreward ?? 100;
  const challengeTitle = template?.title ?? "Daily Challenge";

  // Server-side verification: ensure the user actually met the challenge conditions
  // before awarding XP. This prevents clients from simply marking a challenge done.
  try {
    const userid = challenge.userid;
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const title = (template?.title ?? "").toLowerCase();

    if (title.includes("triple focus")) {
      const sessionsToday = await prisma.focussession.count({
        where: {
          userid,
          status: "COMPLETED",
          endtime: { gte: startOfDay },
        },
      });
      if (sessionsToday < 3) {
        return { success: false, message: "Challenge conditions not met" };
      }
    }

    if (title.includes("task master")) {
      const completedTasksToday = await prisma.task.count({
        where: {
          userid,
          status: "COMPLETED",
          updatedat: { gte: startOfDay },
        },
      });
      if (completedTasksToday < 5) {
        return { success: false, message: "Challenge conditions not met" };
      }
    }

    if (title.includes("note taker")) {
      const notesToday = await prisma.note.count({
        where: {
          userid,
          createdat: { gte: startOfDay },
        },
      });
      if (notesToday < 2) {
        return { success: false, message: "Challenge conditions not met" };
      }
    }

    if (title.includes("early bird")) {
      const firstSession = await prisma.focussession.findFirst({
        where: {
          userid,
          starttime: { gte: startOfDay },
        },
        orderBy: { starttime: "asc" },
      });
      if (!firstSession || !firstSession.starttime) {
        return { success: false, message: "Challenge conditions not met" };
      }
      const hour = new Date(firstSession.starttime).getHours();
      if (hour >= 9) {
        return { success: false, message: "Challenge conditions not met" };
      }
    }
  } catch (err) {
    return { success: false, message: "Failed to verify challenge conditions" };
  }

  await GamificationRepository.createXPTransaction({
    userid: completedchallenge.userid,
    amount: xpReward,
    source: XPSource.CHALLENGE_COMPLETED,
    description: `Completed daily challenge: ${challengeTitle}`,
  });
  await GamificationRepository.incrementUserXP(completedchallenge.userid, xpReward);

  const refreshedChallenges = await GetActiveDailyChallenges(completedchallenge.userid);

  const notificationSettings = await NotificationService.getSettings(completedchallenge.userid);
  if (!notificationSettings || notificationSettings.dailychallengealerts !== false) {
    await NotificationService.scheduleNotification(completedchallenge.userid, {
      type: NotificationType.DAILY_CHALLENGE,
      title: 'Daily Challenge Completed',
      message: `You earned ${xpReward} XP for completing "${challengeTitle}".`,
    });
  }

  return {
    success: true,
    message: "Challenge completed and XP awarded successfully",
    xpReward,
    challenges: refreshedChallenges.success ? refreshedChallenges.data : undefined,
  };
};
