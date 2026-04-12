import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateBlockedAppDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

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

export const AddBlockedApp = async (userid: string, data: CreateBlockedAppDTO) => {
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
};
