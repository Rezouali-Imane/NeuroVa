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
  syncGoogleToTask(eventId: string, accessToken: string): Promise<{
    title: string;
    description: string;
    duedate: Date;
  }>;
  deleteGoogleEvent(eventId: string, accessToken: string): Promise<void>;
  updateCalendarEvent(eventId: string, accessToken: string, data: {
    title: string;
    description?: string;
    deadline?: Date;
  }): Promise<void>;
}
