import {
  classifyTextContent,
  ensureModerationContext,
} from '../../infrastructure/content-moderation/moderation.utils.js';

export const FilterContent = async (userid: string, content: string) => {
  const { policy, blockedDomains } = await ensureModerationContext(userid);
  return classifyTextContent(
    content,
    policy.sensitivitylevel,
    policy.sensitivecontentblockingenabled,
    blockedDomains,
  );
};
