import { DisciplineService } from './DisciplineService.js';
import type { CreateUsageLimitDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const CreateUsageLimit = async (userid: string, data: CreateUsageLimitDTO) => {
  return DisciplineService.createUsageLimit(userid, data);
};
