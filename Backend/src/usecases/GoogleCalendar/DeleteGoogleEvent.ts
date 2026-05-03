import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import type { DeleteGoogleEventDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';
import { refreshToken } from './RefreshToken.js';

export const deleteGoogleEvent = async (dto: DeleteGoogleEventDTO, googleService: GoogleCalendarService) => {
  try {
    const tokenRecord = await GoogleCalendarRepository.getAccessToken(dto.userid);
    if (!tokenRecord) throw new Error("No Google Calendar connection found for this user");

    if (tokenRecord.expiresat < new Date()) {
      await refreshToken({ userid: dto.userid, refreshtoken: tokenRecord.refreshtoken }, googleService);
      const updatedToken = await GoogleCalendarRepository.getAccessToken(dto.userid);
      if (!updatedToken) throw new Error("Failed to retrieve refreshed token");
      tokenRecord.accesstoken = updatedToken.accesstoken;
    }

    await googleService.deleteGoogleEvent(dto.eventid, tokenRecord.accesstoken);
    return await GoogleCalendarRepository.removeGoogleEventFromTask(dto.taskid);
  } catch (error) {
    throw new Error(`Failed to delete Google Calendar event: ${error instanceof Error ? error.message : String(error)}`);
  }
};