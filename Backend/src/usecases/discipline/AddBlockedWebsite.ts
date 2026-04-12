import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateBlockedWebsiteDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

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

export const AddBlockedWebsite = async (userid: string, data: CreateBlockedWebsiteDTO) => {
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
};
