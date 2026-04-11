import { DisciplineService } from './DisciplineService.js';

export const GetTodayUsage = async (userid: string) => {
  return DisciplineService.getTodayUsage(userid);
};
