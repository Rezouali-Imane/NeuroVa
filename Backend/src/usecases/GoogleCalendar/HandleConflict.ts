import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';
import { refreshToken } from './RefreshToken.js';
import prisma from '../../infrastructure/database/prisma.client.js';

export const handleConflict = async (
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

    const googleEvent = await googleCalendarService.syncGoogleToTask(task.googleeventid, tokenRecord.accesstoken);

    const taskUpdatedAt = task.updatedat.getTime();
    const googleUpdatedAt = googleEvent.duedate.getTime();

    if (taskUpdatedAt >= googleUpdatedAt) {
        await googleCalendarService.syncTaskToGoogle(taskid, tokenRecord.accesstoken);
        return { winner: 'task' };
    } else {
        await prisma.task.update({
            where: { taskid },
            data: {
                title: googleEvent.title,
                description: googleEvent.description,
                deadline: googleEvent.duedate,
            },
        });
        return { winner: 'google' };
    }
};