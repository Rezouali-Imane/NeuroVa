import prisma from '../../infrastructure/database/prisma.client.js';
import type { UpdateContentModerationPolicyDTO } from '../../interfaces/dtos/ContentModeration.dto.js';
import { ensurePolicy } from './contentModeration.helpers.js';

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
