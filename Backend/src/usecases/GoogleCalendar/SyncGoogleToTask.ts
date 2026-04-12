import { GoogleCalendarRepository } from "../../interfaces/repositories/GoogleCalendarRepository.js";
import type { GoogleCalendarService } from "../../infrastructure/GoogleCalendar/GoogleCalendarService.js";
import type { SyncGoogleToTaskDTO } from "../../interfaces/dtos/GoogleCalendar.dto.js";
import type { RefreshTokenUseCase } from "./RefreshToken.js";

export class SyncGoogleToTaskUseCase {
  constructor(
    private readonly googleService: GoogleCalendarService,
    private readonly calendarRepo: typeof GoogleCalendarRepository,
    private readonly refreshTokenUseCase: RefreshTokenUseCase,
  ) {}

  async execute(dto: SyncGoogleToTaskDTO) {
    try {
      const tokenRecord = await this.calendarRepo.getAccessToken(dto.userid);

      if (!tokenRecord) {
        throw new Error("No Google Calendar connection found for this user");
      }

      if (tokenRecord.expiresat < new Date()) {
        await this.refreshTokenUseCase.execute({
          userid: dto.userid,
          refreshtoken: tokenRecord.refreshtoken,
        });

        const updatedToken = await this.calendarRepo.getAccessToken(dto.userid);
        if (!updatedToken)
          throw new Error("Failed to retrieve refreshed token");
        tokenRecord.accesstoken = updatedToken.accesstoken;
      }

      const event = await this.googleService.syncGoogleToTask(
        dto.eventid,
        tokenRecord.accesstoken,
      );

      return await this.calendarRepo.createTaskFromGoogleEvent({
        userid: dto.userid,
        listid: dto.listid,
        title: event.title,
        description: event.description,
        deadline: event.duedate,
        googleeventid: dto.eventid,
      });
    } catch (error) {
      throw new Error(`Failed to sync Google event to task: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}
