import prisma from '../../infrastructure/database/prisma.client.js';
import type { AnalyzeImageDTO, ContentModerationDecision } from '../../interfaces/dtos/ContentModeration.dto.js';

const ensurePolicy = async (userid: string) => {
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

export const AnalyzeImage = async (data: AnalyzeImageDTO) => {
  const policy = await ensurePolicy(data.userid);
  const url = data.imageUrl.toLowerCase();
  const blocked = ['nsfw', 'nud', 'blood', 'violence', 'weapon', 'gore'].some((term) =>
    url.includes(term),
  );

  return {
    decision: blocked ? 'BLOCK' : 'ALLOW',
    reason: blocked ? 'Image appears unsafe by heuristic scan' : 'Image allowed',
    confidence: blocked ? 0.88 : 0.74,
    policy: {
      sensitivecontentblockingenabled: policy.sensitivecontentblockingenabled,
      sensitivitylevel: policy.sensitivitylevel as 'NORMAL' | 'SFW_STRICT',
    },
  } satisfies ContentModerationDecision;
};
