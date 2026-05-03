import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import { refreshToken } from './RefreshToken.js';
import prisma from '../../infrastructure/database/prisma.client.js';

export const updateCalendarEvent = async (
    userid: string,
    taskid: string,
    googleCalendarService: GoogleCalendarService
) => {
    const tokenRecord = await GoogleCalendarRepository.getAccessToken(userid);
    if (!tokenRecord) throw new Error('No Google Calendar connection found for this user');

    if (tokenRecord.expiresat < new Date()) {
        await refreshToken({ userid, refreshtoken: tokenRecord.refreshtoken }, googleCalendarService);
        const updated = await GoogleCalendarRepository.getAccessToken(userid);
        if (!updated) throw new Error('Failed to retrieve refreshed token');
        tokenRecord.accesstoken = updated.accesstoken;
    }

    const task = await prisma.task.findUnique({ where: { taskid } });
    if (!task) throw new Error('Task not found');
    if (!task.googleeventid) throw new Error('Task has no linked Google event');

    await googleCalendarService.updateCalendarEvent(task.googleeventid, tokenRecord.accesstoken, {
        title: task.title,
        description: task.description ?? '',
        ...(task.deadline && { deadline: task.deadline }),
    });

    return { updated: true };
};