import type { AnalyzeTextDTO } from '../../interfaces/dtos/ContentModeration.dto.js';
import {
  classifyTextContent,
  ensureModerationContext,
} from '../../infrastructure/content-moderation/moderation.utils.js';

export const AnalyzeText = async (data: AnalyzeTextDTO) => {
  const { policy, blockedDomains } = await ensureModerationContext(data.userid);
  return classifyTextContent(
    data.content,
    policy.sensitivitylevel,
    policy.sensitivecontentblockingenabled,
    blockedDomains,
  );
};
