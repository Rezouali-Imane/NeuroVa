import { DisciplineService } from './DisciplineService.js';
import type { UpdateDigitalDisciplineSettingsDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const UpdateSettings = async (userid: string, data: UpdateDigitalDisciplineSettingsDTO) => {
  return DisciplineService.updateSettings(userid, data);
};
