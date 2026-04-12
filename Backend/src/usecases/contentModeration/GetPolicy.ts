import prisma from '../../infrastructure/database/prisma.client.js';

export const GetPolicy = async (userid: string) => {
  const settings = await prisma.digitaldisciplinesettings.upsert({
    where: { userid },
    update: {},
    create: {
      userid,
      filterlevel: 'NORMAL',
      dailyfreeminutes: 0,
      customblockingenabled: false,
      faithmodeenabled: false,
    },
  });

  return prisma.contentmoderationpolicy.upsert({
    where: { settingsid: settings.settingsid },
    update: {},
    create: {
      settingsid: settings.settingsid,
      sensitivecontentblockingenabled: false,
      sensitivitylevel: 'NORMAL',
    },
  });
};
