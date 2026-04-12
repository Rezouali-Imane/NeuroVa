export interface GoogleCalendarService {
  exchangeCodeForTokens(authCode: string, clientId: string): Promise<{
    access_token: string;
    refresh_token: string;
    expiry_date: number;
  }>;
}