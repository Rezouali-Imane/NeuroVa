import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { DisconnectCalendarDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';

export class DisconnectGoogleCalendarUseCase {
  constructor(
    private readonly calendarRepo: typeof GoogleCalendarRepository,
  ) {}

  async execute(dto: DisconnectCalendarDTO) {
    try {
      return await this.calendarRepo.disconnectCalendar(dto);
    } catch (error) {
      throw new Error(`Failed to disconnect Google Calendar : ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}