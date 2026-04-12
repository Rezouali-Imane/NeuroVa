import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateUsageLogDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

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

export const LogUsage = async (userid: string, data: CreateUsageLogDTO) => {
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
    (matchedLimit && data.usageminutes > matchedLimit.dailylimitminutes) || data.wasblocked === true;

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
};
