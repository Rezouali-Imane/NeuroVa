import { DisciplineService } from './DisciplineService.js';
import type { CreateDisciplineAlertDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const TriggerAlert = async (userid: string, data: CreateDisciplineAlertDTO) => {
  return DisciplineService.triggerAlert(userid, data);
};
