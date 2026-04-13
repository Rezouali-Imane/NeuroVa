import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { DisconnectCalendarDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';

export const disconnectGoogleCalendar = async (dto: DisconnectCalendarDTO) => {
  try {
    return await GoogleCalendarRepository.disconnectCalendar(dto);
  } catch (error) {
    throw new Error(`Failed to disconnect Google Calendar: ${error instanceof Error ? error.message : String(error)}`);
  }
};