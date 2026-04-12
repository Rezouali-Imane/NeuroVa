import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import type { SyncTaskDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';

export class SyncTaskToGoogleUseCase {
  constructor(
    private readonly googleService: GoogleCalendarService,
    private readonly calendarRepo: typeof GoogleCalendarRepository,
  ) {}

  async execute(dto: SyncTaskDTO) {
    try {
      const tokenRecord = await this.calendarRepo.getAccessToken(dto.userid);

      if (!tokenRecord) {
        throw new Error("No Google Calendar connection found for this user");
      }

      const event = await this.googleService.syncTaskToGoogle(dto.taskid, tokenRecord.accesstoken);

      if (!event.googleeventid) {
        throw new Error("Failed to sync task to Google Calendar");
      }

      return await this.calendarRepo.saveGoogleEventId({
        taskid: dto.taskid,
        googleeventid: event.googleeventid,
      });
    } catch (error) {
      throw new Error(`Failed to sync task to Google Calendar`);
    }
  }
}