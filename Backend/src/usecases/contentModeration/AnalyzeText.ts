import type { AnalyzeTextDTO } from '../../interfaces/dtos/ContentModeration.dto.js';
import { ensurePolicy, classifyText } from './contentModeration.helpers.js';

export const AnalyzeText = async (data: AnalyzeTextDTO) => {
  const policy = await ensurePolicy(data.userid);
  return classifyText(data.content, policy.sensitivitylevel, policy.sensitivecontentblockingenabled);
};
