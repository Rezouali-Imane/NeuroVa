import { DisciplineService } from './DisciplineService.js';

export const RemoveBlockedApp = async (userid: string, appid: string) => {
  return DisciplineService.removeBlockedApp(userid, appid);
};
