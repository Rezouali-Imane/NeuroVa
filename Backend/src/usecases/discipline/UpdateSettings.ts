import prisma from '../../infrastructure/database/prisma.client.js';
import type { ContentFilterLevel, UpdateDigitalDisciplineSettingsDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

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

export const UpdateSettings = async (userid: string, data: UpdateDigitalDisciplineSettingsDTO) => {
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
};
