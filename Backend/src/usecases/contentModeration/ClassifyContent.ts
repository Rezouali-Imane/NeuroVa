import prisma from '../../infrastructure/database/prisma.client.js';
import type { ContentModerationDecision } from '../../interfaces/dtos/ContentModeration.dto.js';

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

const classifyText = (
  content: string,
  policyLevel: string,
  blockingEnabled: boolean,
): ContentModerationDecision => {
  const text = content.toLowerCase();
  const unsafeTerms = ['porn', 'nude', 'sex', 'violence', 'kill', 'suicide', 'hate', 'drugs'];
  const sensitiveTerms = ['therapy', 'depression', 'anxiety', 'blood', 'weapon'];
  const unsafeHit = unsafeTerms.some((term) => text.includes(term));
  const sensitiveHit = sensitiveTerms.some((term) => text.includes(term));

  if (
    unsafeHit ||
    (blockingEnabled && sensitiveHit) ||
    (policyLevel === 'SFW_STRICT' && sensitiveHit)
  ) {
    return {
      decision: 'BLOCK',
      reason: unsafeHit ? 'Unsafe content detected' : 'Sensitive content blocked by policy',
      confidence: unsafeHit ? 0.96 : 0.78,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel === 'SFW_STRICT' ? 'SFW_STRICT' : 'NORMAL',
      },
    };
  }

  if (sensitiveHit || text.length < 20) {
    return {
      decision: 'REVIEW',
      reason: 'Content may need review',
      confidence: 0.64,
      policy: {
        sensitivecontentblockingenabled: blockingEnabled,
        sensitivitylevel: policyLevel === 'SFW_STRICT' ? 'SFW_STRICT' : 'NORMAL',
      },
    };
  }

  return {
    decision: 'ALLOW',
    reason: 'Content allowed',
    confidence: 0.9,
    policy: {
      sensitivecontentblockingenabled: blockingEnabled,
      sensitivitylevel: policyLevel === 'SFW_STRICT' ? 'SFW_STRICT' : 'NORMAL',
    },
  };
};

export const ClassifyContent = async (userid: string, content: string) => {
  const policy = await ensurePolicy(userid);
  return classifyText(content, policy.sensitivitylevel, policy.sensitivecontentblockingenabled);
};
