import prisma from '../../infrastructure/database/prisma.client.js';
import type {
  AnalyzeImageDTO,
  AnalyzeTextDTO,
  ContentModerationDecision,
  UpdateContentModerationPolicyDTO,
} from '../../interfaces/dtos/ContentModeration.dto.js';

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

const classifyText = (content: string, policyLevel: string, blockingEnabled: boolean): ContentModerationDecision => {
  const text = content.toLowerCase();
  const unsafeTerms = ['porn', 'nude', 'sex', 'violence', 'kill', 'suicide', 'hate', 'drugs'];
  const sensitiveTerms = ['therapy', 'depression', 'anxiety', 'blood', 'weapon'];
  const unsafeHit = unsafeTerms.some((term) => text.includes(term));
  const sensitiveHit = sensitiveTerms.some((term) => text.includes(term));

  if (unsafeHit || (blockingEnabled && sensitiveHit) || policyLevel === 'SFW_STRICT' && sensitiveHit) {
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

export const ContentModerationService = {
  async getPolicy(userid: string) {
    return ensurePolicy(userid);
  },

  async updatePolicy(userid: string, data: UpdateContentModerationPolicyDTO) {
    const policy = await ensurePolicy(userid);

    const updateData: {
      sensitivecontentblockingenabled?: boolean;
      sensitivitylevel?: 'NORMAL' | 'SFW_STRICT';
    } = {};

    if (typeof data.sensitivecontentblockingenabled === 'boolean') {
      updateData.sensitivecontentblockingenabled = data.sensitivecontentblockingenabled;
    }

    if (data.sensitivitylevel) {
      updateData.sensitivitylevel = data.sensitivitylevel;
    }

    return prisma.contentmoderationpolicy.update({
      where: { policyid: policy.policyid },
      data: updateData,
    });
  },

  async analyzeText(data: AnalyzeTextDTO) {
    const policy = await ensurePolicy(data.userid);
    return classifyText(
      data.content,
      policy.sensitivitylevel,
      policy.sensitivecontentblockingenabled,
    );
  },

  async analyzeImage(data: AnalyzeImageDTO) {
    const policy = await ensurePolicy(data.userid);
    const url = data.imageUrl.toLowerCase();
    const blocked = ['nsfw', 'nud', 'blood', 'violence', 'weapon', 'gore'].some((term) => url.includes(term));

    return {
      decision: blocked ? 'BLOCK' : 'ALLOW',
      reason: blocked ? 'Image appears unsafe by heuristic scan' : 'Image allowed',
      confidence: blocked ? 0.88 : 0.74,
      policy: {
        sensitivecontentblockingenabled: policy.sensitivecontentblockingenabled,
        sensitivitylevel: policy.sensitivitylevel as 'NORMAL' | 'SFW_STRICT',
      },
    } satisfies ContentModerationDecision;
  },

  async filterContent(userid: string, content: string) {
    const policy = await ensurePolicy(userid);
    return classifyText(content, policy.sensitivitylevel, policy.sensitivecontentblockingenabled);
  },
};
