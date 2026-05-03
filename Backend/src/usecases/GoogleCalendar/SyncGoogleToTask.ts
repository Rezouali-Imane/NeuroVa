import { GoogleCalendarRepository } from "../../interfaces/repositories/GoogleCalendarRepository.js";
import type { GoogleCalendarService } from "../../infrastructure/GoogleCalendar/GoogleCalendarService.js";
import type { SyncGoogleToTaskDTO } from "../../interfaces/dtos/GoogleCalendar.dto.js";
import { refreshToken } from "./RefreshToken.js";

export const syncGoogleToTask = async (dto: SyncGoogleToTaskDTO, googleService: GoogleCalendarService) => {
  try {
    const tokenRecord = await GoogleCalendarRepository.getAccessToken(dto.userid);
    if (!tokenRecord) throw new Error("No Google Calendar connection found for this user");

    if (tokenRecord.expiresat < new Date()) {
      await refreshToken({ userid: dto.userid, refreshtoken: tokenRecord.refreshtoken }, googleService);
      const updatedToken = await GoogleCalendarRepository.getAccessToken(dto.userid);
      if (!updatedToken) throw new Error("Failed to retrieve refreshed token");
      tokenRecord.accesstoken = updatedToken.accesstoken;
    }

    const event = await googleService.syncGoogleToTask(dto.eventid, tokenRecord.accesstoken);

    return await GoogleCalendarRepository.createTaskFromGoogleEvent({
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
};