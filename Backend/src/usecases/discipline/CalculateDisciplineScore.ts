import { DisciplineService } from './DisciplineService.js';

export const CalculateDisciplineScore = async (userid: string) => {
  return DisciplineService.calculateDisciplineScore(userid);
};
