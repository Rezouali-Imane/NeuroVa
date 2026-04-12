import { ensurePolicy, classifyText } from './contentModeration.helpers.js';

export const FilterContent = async (userid: string, content: string) => {
  const policy = await ensurePolicy(userid);
  return classifyText(content, policy.sensitivitylevel, policy.sensitivecontentblockingenabled);
};
