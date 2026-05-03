import { google } from 'googleapis';
import type { GoogleCalendarService } from './GoogleCalendarService.js';
import prisma from "../database/prisma.client.js";

const clientSecret = process.env.GOOGLE_CLIENT_SECRET!;
const redirectUri = process.env.GOOGLE_REDIRECT_URI!;

const createOAuthClient = (clientId: string, accessToken?: string, refreshToken?: string) => {
  const oauth2Client = new google.auth.OAuth2(clientId, clientSecret, redirectUri);
  if (accessToken) {
    oauth2Client.setCredentials({
      access_token: accessToken,
      refresh_token: refreshToken ?? null,
    });
  }
  return oauth2Client;
};

export const googleCalendarService: GoogleCalendarService = {
  async exchangeCodeForTokens(authCode, clientId) {
    const oauth2Client = createOAuthClient(clientId);
    const { tokens } = await oauth2Client.getToken(authCode);

    if (!tokens.access_token || !tokens.refresh_token || !tokens.expiry_date) {
      throw new Error('Incomplete tokens received from Google');
    }

    return {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expiry_date: tokens.expiry_date,
    };
  },

  async refreshAccessToken(refreshToken, clientId) {
    const oauth2Client = createOAuthClient(clientId, undefined, refreshToken);
    const { credentials } = await oauth2Client.refreshAccessToken();

    if (!credentials.access_token || !credentials.expiry_date) {
      throw new Error('Failed to refresh access token');
    }

    return {
      access_token: credentials.access_token,
      expiry_date: credentials.expiry_date,
    };
  },

  async syncTaskToGoogle(taskId: string, accessToken: string) {
    const task = await prisma.task.findUnique({ where: { taskid: taskId}});
    if (!task) throw new Error('Task not found');

    const oauth2Client = createOAuthClient(process.env.GOOGLE_CLIENT_ID!, accessToken);
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    const { data } = await calendar.events.insert({
      calendarId: 'primary',
      requestBody: {
        summary: task.title,
        description: task.description ?? '',
        start: { dateTime: new Date().toISOString() },
        end: { dateTime: new Date().toISOString() },
      },
    });

    if (!data.id) throw new Error('Failed to create Google Calendar event');

    return { googleeventid: data.id };
  },

  async syncGoogleToTask(eventId, accessToken) {
    const oauth2Client = createOAuthClient(process.env.GOOGLE_CLIENT_ID!, accessToken);
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    const { data } = await calendar.events.get({
      calendarId: 'primary',
      eventId,
    });

    return {
      title: data.summary ?? '',
      description: data.description ?? '',
      duedate: new Date(data.end?.dateTime ?? data.end?.date ?? Date.now()),
    };
  },

  async deleteGoogleEvent(eventId, accessToken) {
    const oauth2Client = createOAuthClient(process.env.GOOGLE_CLIENT_ID!, accessToken);
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    await calendar.events.delete({
      calendarId: 'primary',
      eventId,
    });
  },

  async updateCalendarEvent(eventId: string, accessToken: string, data: { title: string; description?: string; deadline?: Date }) {
    const oauth2Client = createOAuthClient(process.env.GOOGLE_CLIENT_ID!, accessToken);
    const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

    const startTime = data.deadline ?? new Date();
    const endTime = new Date(startTime.getTime() + 60 * 60 * 1000);

    await calendar.events.patch({
      calendarId: 'primary',
      eventId,
      requestBody: {
        summary: data.title,
        description: data.description ?? '',
        start: { dateTime: startTime.toISOString() },
        end: { dateTime: endTime.toISOString() },
      },
    });
  },
};