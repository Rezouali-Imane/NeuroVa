import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  AwardBadgeDTO,
  AwardAchievementDTO,
  AwardXPDTO,
  AssignDailyChallengeDTO,
  getDailyChallengeDTO,
  GetLeaderboardDTO,
  updateLeaderboardDTO,
  updateStreakDTO,
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

  //____________________Leaderboard___________________

  async upsertLeaderboardEntry(updateLeaderboardDTO: updateLeaderboardDTO) {
    const { leaderboardid, userid, xppoints } = updateLeaderboardDTO;

    return await prisma.leaderboardentry.upsert({
      where: {
        leaderboardid_userid: {
          leaderboardid,
          userid,
        },
      },
      update: {
        xppoints: xppoints,
      },
      create: {
        leaderboardid,
        userid,
        xppoints,
        rank: 0,
      },
    });
  },

  async UpdateRanks(GetLeaderboardDTO: GetLeaderboardDTO) {
    const entries = await prisma.leaderboardentry.findMany({
      where: { leaderboardid: GetLeaderboardDTO.leaderboardid },
      orderBy: { xppoints: "desc" },
    });

    const updates = entries.map((entry, index) =>
      prisma.leaderboardentry.update({
        where: { entryid: entry.entryid },
        data: { rank: index + 1 },
      }),
    );

    return await prisma.$transaction(updates);
  },
  async GetLeaderboardTopN(GetLeaderboardDTO: GetLeaderboardDTO) {
    return await prisma.leaderboardentry.findMany({
      where: { leaderboardid: GetLeaderboardDTO.leaderboardid },
      orderBy: { xppoints: "desc" },
      take: GetLeaderboardDTO.limit || 10,
    });
  },

  //____________________Daily Challenges___________________
  async CreatDailyChallenge(data: AssignDailyChallengeDTO) {
    return await prisma.dailychallenge.create({
      data,
    });
  },
  async fundChallengeById(getdailyChallengeDTO: getDailyChallengeDTO) {
    return await prisma.dailychallenge.findUnique({
      where: { challengeid: getdailyChallengeDTO.challengeid },
    });
  },
  async findactiveChallengeByUserId(userid: string) {
    const now = new Date();
    return await prisma.dailychallenge.findFirst({
      where: {
        userid,
        expiresat: { gt: now },
        iscompleted: false,
      },
    });
  },
  async completeDailyChallenge(getdailyChallengeDTO: getDailyChallengeDTO) {
    const now = new Date();
    return await prisma.dailychallenge.update({
      where: { challengeid: getdailyChallengeDTO.challengeid },
      data: { iscompleted: true, completedat: now },
    });
  },

  async getChallengeTemplateById(templateid: string) {
    return await prisma.dailychallengetemplate.findUnique({
      where: { templateid },
    });
  },
  //____________________Streak Bonus___________________
  async updateStreakBonus(updateStreakDTO: updateStreakDTO) {
    const user = await prisma.users.findUnique({
      where: { userid: updateStreakDTO.userid },
    });
    if (!user) throw new Error("User not found");

    const newStreakBonus = user.xppoints + updateStreakDTO.bonusxp;

    return await prisma.users.update({
      where: { userid: updateStreakDTO.userid },
      data: { xppoints: newStreakBonus },
    });
  },
};
