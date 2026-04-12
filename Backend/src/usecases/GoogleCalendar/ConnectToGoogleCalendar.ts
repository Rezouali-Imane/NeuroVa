import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { ConnectCalendarDTO } from '../../interfaces/dtos/GoogleCalendar.dto.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';

export class ConnectGoogleCalendarUseCase {
  private readonly clientId: string = process.env.GOOGLE_CLIENT_ID!;

  constructor(
    private readonly googleService: GoogleCalendarService,
    private readonly calendarRepo: typeof GoogleCalendarRepository,
  ) {}

  async execute(dto: ConnectCalendarDTO) {
    try {
      const tokens = await this.googleService.exchangeCodeForTokens(dto.authcode, this.clientId);

      if (!tokens.access_token || !tokens.refresh_token) {
        throw new Error("Invalid tokens received from Google");
      }

      return await this.calendarRepo.connectCalendar({
        userid: dto.userid,
        accesstoken: tokens.access_token,
        refreshtoken: tokens.refresh_token,
        expiresat: new Date(tokens.expiry_date),
      });
    } catch (error) {
      throw new Error(`Failed to connect Google Calendar: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}