import { DisciplineService } from './DisciplineService.js';
import type { CreateBlockedAppDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const AddBlockedApp = async (userid: string, data: CreateBlockedAppDTO) => {
  return DisciplineService.addBlockedApp(userid, data);
};
