import prisma from '../../infrastructure/database/prisma.client.js';
import type {
  ContentFilterLevel,
  CreateBlockedAppDTO,
  CreateBlockedWebsiteDTO,
  CreateDisciplineAlertDTO,
  CreateUsageLimitDTO,
  CreateUsageLogDTO,
  UpdateDigitalDisciplineSettingsDTO,
  UpdateDisciplineScoreDTO,
} from '../../interfaces/dtos/DigitalDiscipline.dto.js';

const normalizeDate = (date: Date) => {
  const normalized = new Date(date);
  normalized.setHours(0, 0, 0, 0);
  return normalized;
};

const getOrCreateSettings = async (userid: string) => {
  const settings = await prisma.digitaldisciplinesettings.findUnique({
    where: { userid },
    include: {
      blockedapp: true,
      blockedwebsite: true,
      usagelimit: true,
      contentmoderationpolicy: true,
    },
  });

  if (settings) {
    return settings;
  }

  return prisma.digitaldisciplinesettings.create({
    data: {
      userid,
      filterlevel: 'NORMAL',
      dailyfreeminutes: 0,
      customblockingenabled: false,
      faithmodeenabled: false,
    },
    include: {
      blockedapp: true,
      blockedwebsite: true,
      usagelimit: true,
      contentmoderationpolicy: true,
    },
  });
};

export const DisciplineService = {
  getSettings: getOrCreateSettings,

  async updateSettings(userid: string, data: UpdateDigitalDisciplineSettingsDTO) {
    await getOrCreateSettings(userid);

    return prisma.digitaldisciplinesettings.update({
      where: { userid },
      data: {
        filterlevel: data.filterlevel as ContentFilterLevel | undefined,
        dailyfreeminutes: data.dailyfreeminutes,
        customblockingenabled: data.customblockingenabled,
        faithmodeenabled: data.faithmodeenabled,
      } as any,
      include: {
        blockedapp: true,
        blockedwebsite: true,
        usagelimit: true,
        contentmoderationpolicy: true,
      },
    });
  },

  async addBlockedApp(userid: string, data: CreateBlockedAppDTO) {
    const settings = await getOrCreateSettings(userid);

    const existing = await prisma.blockedapp.findFirst({
      where: {
        settingsid: settings.settingsid,
        appname: data.appname,
      },
    });

    if (existing) {
      return existing;
    }

    return prisma.blockedapp.create({
      data: {
        settingsid: settings.settingsid,
        appname: data.appname,
      },
    });
  },

  async removeBlockedApp(userid: string, appid: string) {
    await getOrCreateSettings(userid);
    return prisma.blockedapp.delete({
      where: { appid },
    });
  },

  async addBlockedWebsite(userid: string, data: CreateBlockedWebsiteDTO) {
    const settings = await getOrCreateSettings(userid);

    const existing = await prisma.blockedwebsite.findFirst({
      where: {
        settingsid: settings.settingsid,
        domain: data.domain,
      },
    });

    if (existing) {
      return existing;
    }

    return prisma.blockedwebsite.create({
      data: {
        settingsid: settings.settingsid,
        domain: data.domain,
      },
    });
  },

  async removeBlockedWebsite(userid: string, websiteid: string) {
    await getOrCreateSettings(userid);
    return prisma.blockedwebsite.delete({
      where: { websiteid },
    });
  },

  async createUsageLimit(userid: string, data: CreateUsageLimitDTO) {
    const settings = await getOrCreateSettings(userid);

    return prisma.usagelimit.create({
      data: {
        settingsid: settings.settingsid,
        appname: data.appname,
        packagename: data.packagename ?? null,
        dailylimitminutes: data.dailylimitminutes,
        isactive: data.isactive ?? true,
      },
    });
  },

  async logUsage(userid: string, data: CreateUsageLogDTO) {
    const settings = await getOrCreateSettings(userid);
    const usageLog = await prisma.usagelog.create({
      data: {
        userid,
        appname: data.appname,
        packagename: data.packagename ?? null,
        usageminutes: data.usageminutes,
        wasblocked: data.wasblocked ?? false,
        logdate: data.logdate ?? new Date(),
      },
    });

    const matchedLimit = await prisma.usagelimit.findFirst({
      where: {
        settingsid: settings.settingsid,
        appname: data.appname,
        isactive: true,
      },
      orderBy: { createdat: 'desc' },
    });

    const shouldAlert =
      (matchedLimit && data.usageminutes > matchedLimit.dailylimitminutes) ||
      data.wasblocked === true;

    if (shouldAlert) {
      await prisma.disciplinealert.create({
        data: {
          userid,
          appname: data.appname,
          identifier: data.packagename ?? data.appname,
          alerttype: data.wasblocked ? 'BLOCKED_USAGE' : 'LIMIT_EXCEEDED',
          message: data.wasblocked
            ? `Usage blocked for ${data.appname}`
            : `Daily usage limit exceeded for ${data.appname}`,
        },
      });
    }

    return usageLog;
  },

  async getTodayUsage(userid: string) {
    const start = new Date();
    start.setHours(0, 0, 0, 0);

    const end = new Date(start);
    end.setDate(end.getDate() + 1);

    const logs = await prisma.usagelog.findMany({
      where: {
        userid,
        logdate: {
          gte: start,
          lt: end,
        },
      },
      orderBy: { logdate: 'desc' },
    });

    const totalMinutes = logs.reduce((sum, log) => sum + log.usageminutes, 0);
    const blockedCount = logs.filter((log) => log.wasblocked).length;

    return {
      userid,
      totalMinutes,
      blockedCount,
      entries: logs,
    };
  },

  async triggerAlert(userid: string, data: CreateDisciplineAlertDTO) {
    return prisma.disciplinealert.create({
      data: {
        userid,
        appname: data.appname ?? null,
        identifier: data.identifier ?? null,
        alerttype: data.alerttype,
        message: data.message,
        isread: data.isread ?? false,
      },
    });
  },

  async calculateDisciplineScore(userid: string) {
    const logs = await prisma.usagelog.findMany({
      where: { userid },
      orderBy: { logdate: 'desc' },
      take: 30,
    });

    const alerts = await prisma.disciplinealert.findMany({
      where: { userid, isread: false },
    });

    const blockedCount = logs.filter((log) => log.wasblocked).length;
    const minutes = logs.reduce((sum, log) => sum + log.usageminutes, 0);
    const totalPenalty = Math.min(50, blockedCount * 10 + Math.floor(minutes / 180) + alerts.length * 4);
    const score = Math.max(0, 100 - totalPenalty);
    const violationcount = blockedCount + alerts.length;
    const streak = Math.max(0, Math.floor((100 - totalPenalty) / 10));
    const scoredate = normalizeDate(new Date());

    return prisma.disciplinescore.upsert({
      where: {
        userid_scoredate: {
          userid,
          scoredate,
        },
      },
      update: {
        score,
        violationcount,
        streak,
      },
      create: {
        userid,
        score,
        violationcount,
        streak,
        scoredate,
      },
    });
  },
};
