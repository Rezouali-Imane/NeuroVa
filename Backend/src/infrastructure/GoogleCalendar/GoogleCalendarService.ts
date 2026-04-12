export interface GoogleCalendarService {
  exchangeCodeForTokens(authCode: string, clientId: string): Promise<{
    access_token: string;
    refresh_token: string;
    expiry_date: number;
  }>;
  refreshAccessToken(refreshToken: string, clientId: string): Promise<{
    access_token: string;
    expiry_date: number;
  }>;
    syncTaskToGoogle(taskId: string, accessToken: string): Promise<{
    googleeventid: string;
  }>;
}
