import type { GoogleCalendarService } from "../../infrastructure/GoogleCalendar/GoogleCalendarService.js";
import { GoogleCalendarRepository } from "../../interfaces/repositories/GoogleCalendarRepository.js";
import type { refreshAccessTokenDTO } from "../../interfaces/dtos/GoogleCalendar.dto.js";

export class RefreshTokenUseCase {
     private readonly clientId: string = process.env.GOOGLE_CLIENT_ID!;
  constructor(
    private googleCalendarService: GoogleCalendarService,
    private googleCalendarRepository: typeof GoogleCalendarRepository
  ) {}
  async execute(dto: refreshAccessTokenDTO) {
    try {
      const token = await this.googleCalendarService.refreshAccessToken(dto.refreshtoken, this.clientId);
      return await this.googleCalendarRepository.updateAccessToken({
        userid: dto.userid,
        accesstoken: token.access_token,
        expiresat: new Date(token.expiry_date),
      });
    } catch (error) {
      throw new Error(`Failed to refresh access token: ${error instanceof Error ? error.message : String(error)}`);
    }

}
}