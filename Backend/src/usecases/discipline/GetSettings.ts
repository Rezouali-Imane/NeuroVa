import prisma from '../../infrastructure/database/prisma.client.js';
import { DEFAULT_BLOCKED_DOMAINS } from '../../infrastructure/content-moderation/moderation.utils.js';

export const GetSettings = async (userid: string) => {
  let settings = await prisma.digitaldisciplinesettings.findUnique({
    where: { userid },
    include: {
      blockedapp: true,
      blockedwebsite: true,
      usagelimit: true,
      contentmoderationpolicy: true,
    },
  });

  if (!settings) {
    settings = await prisma.digitaldisciplinesettings.create({
      data: {
        userid,
        filterlevel: 'SFW_STRICT',
        dailyfreeminutes: 0,
        customblockingenabled: true,
        faithmodeenabled: false,
      },
      include: {
        blockedapp: true,
        blockedwebsite: true,
        usagelimit: true,
        contentmoderationpolicy: true,
      },
    });
  }

  const existingDomains = new Set(
    (settings.blockedwebsite ?? []).map((website) => website.domain.toLowerCase()),
  );
  const missingDefaults = DEFAULT_BLOCKED_DOMAINS.filter(
    (domain) => !existingDomains.has(domain.toLowerCase()),
  );

  if (missingDefaults.length > 0) {
    const settingsId = settings?.settingsid;
    if (!settingsId) {
      throw new Error('Unable to resolve discipline settings id');
    }

    await prisma.blockedwebsite.createMany({
      data: missingDefaults.map((domain) => ({
        settingsid: settingsId,
        domain,
      })),
    });

    const refreshedSettings = await prisma.digitaldisciplinesettings.findUnique({
      where: { userid },
      include: {
        blockedapp: true,
        blockedwebsite: true,
        usagelimit: true,
        contentmoderationpolicy: true,
      },
    });

    if (refreshedSettings) {
      settings = refreshedSettings;
    }
  }

  if (!settings) {
    throw new Error('Unable to resolve discipline settings');
  }

  return settings;
};
