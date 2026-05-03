import type { GoogleCalendarService } from "../../infrastructure/GoogleCalendar/GoogleCalendarService.js";
import { GoogleCalendarRepository } from "../../interfaces/repositories/GoogleCalendarRepository.js";
import type { refreshAccessTokenDTO } from "../../interfaces/dtos/GoogleCalendar.dto.js";

export const refreshToken = async (dto: refreshAccessTokenDTO, googleService: GoogleCalendarService) => {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) throw new Error('GOOGLE_CLIENT_ID is not set');

  try {
    const token = await googleService.refreshAccessToken(dto.refreshtoken, clientId);
    return await GoogleCalendarRepository.updateAccessToken({
      userid: dto.userid,
      accesstoken: token.access_token,
      expiresat: new Date(token.expiry_date),
    });
  } catch (error) {
    throw new Error(`Failed to refresh access token: ${error instanceof Error ? error.message : String(error)}`);
  }
};