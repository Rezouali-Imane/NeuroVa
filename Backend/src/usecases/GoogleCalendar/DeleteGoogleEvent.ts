import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import type { DeleteGoogleEventDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';
import { RefreshTokenUseCase } from './RefreshToken.js';

export class DeleteGoogleEventUseCase {
  constructor(
    private readonly googleService: GoogleCalendarService,
    private readonly calendarRepo: typeof GoogleCalendarRepository,
    private readonly refreshTokenUseCase: RefreshTokenUseCase,
  ) {}

  async execute(dto: DeleteGoogleEventDTO) {
    try {
      // Step 1: Get the user's access token
      const tokenRecord = await this.calendarRepo.getAccessToken(dto.userid);

      if (!tokenRecord) {
        throw new Error("No Google Calendar connection found for this user");
      }

      // Step 2: Check if token is expired and refresh if needed
      if (tokenRecord.expiresat < new Date()) {
        await this.refreshTokenUseCase.execute({
          userid: dto.userid,
          refreshtoken: tokenRecord.refreshtoken,
        });

        const updatedToken = await this.calendarRepo.getAccessToken(dto.userid);
        if (!updatedToken) throw new Error("Failed to retrieve refreshed token");
        tokenRecord.accesstoken = updatedToken.accesstoken;
      }

      // Step 3: Delete event from Google Calendar
      await this.googleService.deleteGoogleEvent(dto.eventid, tokenRecord.accesstoken);

      // Step 4: Remove google event id from task
      return await this.calendarRepo.removeGoogleEventFromTask(dto.taskid);
    } catch (error) {
      throw new Error(`Failed to delete Google Calendar event: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}