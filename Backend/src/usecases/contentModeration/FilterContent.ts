import { ContentModerationService } from './ContentModerationService.js';

export const FilterContent = async (userid: string, content: string) => {
  return ContentModerationService.filterContent(userid, content);
};
