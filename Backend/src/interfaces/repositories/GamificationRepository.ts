import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  AwardBadgeDTO,
  AwardAchievementDTO,
  AwardXPDTO,
  AssignDailyChallengeDTO,
  getDailyChallengeDTO,
  GetLeaderboardDTO,
  updateLeaderboardDTO,
} from "../dtos/Gamification.dto.js";

export const GamificationRepository = {
  // ___________________XP Transactions___________________

  async creatXPTransaction(data: AwardXPDTO) {
    return await prisma.xptransaction.create({
      data: {
        userid : data.userid,
        amount : data.amount,
        source : data.source,
        description : data.description,
      },
    });
  },

  async incrementuserXP(userid: string, amount: number) {
    return await prisma.users.update({
      where: { userid },
      data: { xppoints: { increment: amount } },
    });
  },

  async getXPHistory(userid: string) {
    return await prisma.xptransaction.findMany({
      where: { userid },
      orderBy: { createdat: "desc" },
    });
  },

  // ___________________Achievements___________________

  async createAchievement(data: AwardAchievementDTO) {
    return await prisma.achievement.create({
      data: {
        userid : data.userid,
        title: data.title,
        description: data.description,
        pointsreward: data.pointsreward,
      },
    });
  },

  async getAchievementsByTitle(title: string, userid: string) {
    return await prisma.achievement.findMany({
      where: { title, userid },
    });
  },
  async getAllAchievementsByUser(userid: string) {
    return await prisma.achievement.findMany({
      where: { userid },
    });
  },

  // ___________________Badge___________________

  async createBadge(data: AwardBadgeDTO) {
    return await prisma.badge.create({
      data: {
        userid : data.userid,
        name: data.name,
        description: data.description,
        iconurl: data.iconurl,
        condition: data.condition,
      },
    });
  },

  async getBadgeByName(name: string, userid: string) {
    return await prisma.badge.findMany({
      where: { name, userid },
    });
  },

  async getAllBadgesByUser(userid: string) {
    return await prisma.badge.findMany({
      where: { userid },
    });
  },

  //____________________Leaderboard___________________

  async upsertLeaderboardEntry(data: updateLeaderboardDTO) {
    return await prisma.leaderboardentry.upsert({
      where: {
        leaderboardid_userid: {
          leaderboardid: data.leaderboardid,
          userid: data.userid,
        },
      },
      update: {
        xppoints: data.xppoints,
      },
      create: {
        leaderboardid: data.leaderboardid,
        userid: data.userid,
        xppoints: data.xppoints,
        rank: 0,
      },
    });
  },

  async updateRanks(data: GetLeaderboardDTO) {
    const entries = await prisma.leaderboardentry.findMany({
      where: { leaderboardid: data.leaderboardid },
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

  async getLeaderboardTopN(data: GetLeaderboardDTO) {
    return await prisma.leaderboardentry.findMany({
      where: { leaderboardid: data.leaderboardid },
      orderBy: { xppoints: "asc" },
      take: data.limit ?? 10,
    });
  },

  //____________________Daily Challenges___________________
  async creatDailyChallenge(data: AssignDailyChallengeDTO) {
    return await prisma.dailychallenge.create({
      data: {
        userid : data.userid,
        templateid : data.templateid,
        expiresat : data.expiresat,
      },
    });
  },

  async findChallengeById(data: getDailyChallengeDTO) {
    return await prisma.dailychallenge.findUnique({
      where: { challengeid: data.challengeid },
    });
  },

  async findactiveChallengeByUserId(userid: string) {
    return await prisma.dailychallenge.findFirst({
      where: {
        userid,
        expiresat: { gt: new Date() },
        iscompleted: false,
      },
    });
  },

  async getAllChallengesByUser(userid: string) {
    return await prisma.dailychallenge.findMany({
      where: { userid },
      orderBy: { assignedat: "desc" },
    });
  },

  async completeDailyChallenge(data: getDailyChallengeDTO) {
    return await prisma.dailychallenge.update({
      where: { challengeid: data.challengeid },
      data: { iscompleted: true, completedat: new Date() },
    });
  },

  async getChallengeTemplateById(templateid: string) {
    return await prisma.dailychallengetemplate.findUnique({
      where: { templateid },
    });
  },
  //____________________ Streak ___________________

  async getlastCompletedSession(userid: string) {
    return await prisma.focussession.findFirst({
      where: {
        userid,
        status: "COMPLETED",
        endtime: { not: null },
      },
      orderBy: { endtime: "desc"},
    });
  },

  async getCurrentStreak(userid: string) {
    const student = await prisma.student.findUnique({
      where: { userid },
    });
    return student?.focusstreak ?? 0;
  },

  async updateStreak(userid: string, streak: number) {
    return await prisma.student.update({
      where: { userid },
      data: { focusstreak: streak},
    });
  },

  // ___________________ Focus Score___________________

  async updateFocusScore(sessionid: string, score: number) {
    return await prisma.focussession.update({
      where: { sessionid },
      data: { focusscore: score },
    });
  },
};
