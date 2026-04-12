import { ensurePolicy } from './contentModeration.helpers.js';

export const GetPolicy = async (userid: string) => {
  return ensurePolicy(userid);
};
