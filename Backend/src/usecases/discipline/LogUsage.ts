import { DisciplineService } from './DisciplineService.js';
import type { CreateUsageLogDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const LogUsage = async (userid: string, data: CreateUsageLogDTO) => {
  return DisciplineService.logUsage(userid, data);
};
