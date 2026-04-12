import prisma from '../../infrastructure/database/prisma.client.js';

export const GetSettings = async (userid: string) => {
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
