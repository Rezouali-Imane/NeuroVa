import { DisciplineService } from './DisciplineService.js';

export const RemoveBlockedWebsite = async (userid: string, websiteid: string) => {
  return DisciplineService.removeBlockedWebsite(userid, websiteid);
};
