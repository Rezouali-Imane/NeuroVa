import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import type { SyncTaskDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';
import { refreshToken } from './RefreshToken.js';

export const syncTaskToGoogle = async (dto: SyncTaskDTO, googleService: GoogleCalendarService) => {
  try {
    const tokenRecord = await GoogleCalendarRepository.getAccessToken(dto.userid);
    if (!tokenRecord) throw new Error("No Google Calendar connection found for this user");

    if (tokenRecord.expiresat < new Date()) {
      await refreshToken({ userid: dto.userid, refreshtoken: tokenRecord.refreshtoken }, googleService);
      const updatedToken = await GoogleCalendarRepository.getAccessToken(dto.userid);
      if (!updatedToken) throw new Error("Failed to retrieve refreshed token");
      tokenRecord.accesstoken = updatedToken.accesstoken;
    }

    const event = await googleService.syncTaskToGoogle(dto.taskid, tokenRecord.accesstoken);
    if (!event.googleeventid) throw new Error("Failed to sync task to Google Calendar");

    return await GoogleCalendarRepository.saveGoogleEventId({
      taskid: dto.taskid,
      googleeventid: event.googleeventid,
    });
  } catch (error) {
    throw new Error(`Failed to sync task to Google Calendar: ${error instanceof Error ? error.message : String(error)}`);
  }
};