import { DisciplineService } from './DisciplineService.js';
import type { CreateBlockedWebsiteDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const AddBlockedWebsite = async (userid: string, data: CreateBlockedWebsiteDTO) => {
  return DisciplineService.addBlockedWebsite(userid, data);
};
