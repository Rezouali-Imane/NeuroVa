import { ContentModerationService } from './ContentModerationService.js';

export const ClassifyContent = async (userid: string, content: string) => {
  return ContentModerationService.filterContent(userid, content);
};
