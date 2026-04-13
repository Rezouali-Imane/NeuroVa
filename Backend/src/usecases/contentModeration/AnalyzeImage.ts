import type { AnalyzeImageDTO } from '../../interfaces/dtos/ContentModeration.dto.js';
import {
  classifyImageUrl,
  ensureModerationContext,
} from '../../infrastructure/content-moderation/moderation.utils.js';

export const AnalyzeImage = async (data: AnalyzeImageDTO) => {
  const { policy, blockedDomains } = await ensureModerationContext(data.userid);
  return classifyImageUrl(
    data.imageUrl,
    policy.sensitivitylevel,
    policy.sensitivecontentblockingenabled,
    blockedDomains,
  );
};
