import { DisciplineService } from './DisciplineService.js';

export const GetSettings = async (userid: string) => {
  return DisciplineService.getSettings(userid);
};
