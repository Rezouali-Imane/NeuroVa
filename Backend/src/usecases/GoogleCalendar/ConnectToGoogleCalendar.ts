import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { ConnectCalendarDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';

export const connectGoogleCalendar = async (
  dto: ConnectCalendarDTO,
  googleService: GoogleCalendarService
) => {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) throw new Error('GOOGLE_CLIENT_ID is not set');

  try {
    const tokens = await googleService.exchangeCodeForTokens(dto.authcode, clientId);

    if (!tokens.access_token || !tokens.refresh_token) {
      throw new Error('Invalid tokens received from Google');
    }

    return await GoogleCalendarRepository.connectCalendar({
      userid: dto.userid,
      accesstoken: tokens.access_token,
      refreshtoken: tokens.refresh_token,
      expiresat: new Date(tokens.expiry_date),
    });
  } catch (error) {
    throw new Error(`Failed to connect Google Calendar: ${error instanceof Error ? error.message : String(error)}`);
  }
};