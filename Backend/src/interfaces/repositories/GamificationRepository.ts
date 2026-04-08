import { get } from "node:http";
import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  AwardBadgeDTO,
  AwardAchievementDTO,
  AwardXPDTO,
  AssignDailyChallengeDTO,
  CompleteDailyChallengeDTO,
  GetLeaderboardDTO,
  updateLeaderboardDTO,
} from "../dtos/Gamification.dto.js";

export const GamificationRepository = {
  // ___________________XP Transactions___________________

  async CreatXPtransaction(data: AwardXPDTO) {
    return await prisma.xptransaction.create({
      data,
    });
  },

  async GetXPHistory(userid: string) {
    return await prisma.xptransaction.findMany({
      where: { userid },
      orderBy: { createdat: "desc" },
    });
  },

  // ___________________Achievement___________________

  async CreateAchivement(data: AwardAchievementDTO) {
    return await prisma.achievement.create({
      data,
    });
  },

  async GetAchivementsByTitle(title: string, userid: string) {
    return await prisma.achievement.findMany({
      where: { title, userid },
    });
  },
  async GetAllAchivementsByUser(userid: string) {
    return await prisma.achievement.findMany({
      where: { userid },
    });
  },

  // ___________________Badge___________________

  async CreateBadge(data: AwardBadgeDTO) {
    return await prisma.badge.create({
      data,
    });
  },

  async GetBadgeByName(name: string, userid: string) {
    return await prisma.badge.findMany({
      where: { name, userid },
    });
  },

  async GetAllBadgesByUser(userid: string) {
    return await prisma.badge.findMany({
      where: { userid },
    });
  },

};
