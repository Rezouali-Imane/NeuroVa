import { GoogleCalendarRepository } from '../../interfaces/repositories/GoogleCalendarRepository.js';
import { syncTaskToGoogle } from './SyncTaskToGoogle.js';
import { syncGoogleToTask } from './SyncGoogleToTask.js';
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';

export const fullSync = async (userid: string, listid: string, googleCalendarService: GoogleCalendarService) => {
    const syncRecord = await GoogleCalendarRepository.getSync(userid);
    if (!syncRecord || !syncRecord.isenabled) throw new Error('Google Calendar sync is not enabled for this user');

    const unsyncedTasks = await GoogleCalendarRepository.getUnsyncedTasks(userid);

    let pushed = 0;
    for (const task of unsyncedTasks) {
        await syncTaskToGoogle({ userid, taskid: task.taskid }, googleCalendarService);
        pushed++;
    }

    await GoogleCalendarRepository.updateLastSynced(userid);

    return { pushed };
};