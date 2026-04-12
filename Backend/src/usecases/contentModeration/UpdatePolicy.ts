import prisma from '../../infrastructure/database/prisma.client.js';
import type { UpdateContentModerationPolicyDTO } from '../../interfaces/dtos/ContentModeration.dto.js';

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

export const UpdatePolicy = async (userid: string, data: UpdateContentModerationPolicyDTO) => {
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
};
