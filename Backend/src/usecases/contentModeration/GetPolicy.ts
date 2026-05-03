import { ensureModerationContext } from '../../infrastructure/content-moderation/moderation.utils.js';

export const GetPolicy = async (userid: string) => {
  const { policy } = await ensureModerationContext(userid);
  return policy;
};
