import { ContentModerationService } from './ContentModerationService.js';

export const GetPolicy = async (userid: string) => {
  return ContentModerationService.getPolicy(userid);
};
