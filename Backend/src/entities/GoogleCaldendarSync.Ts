export interface GoogleCalendarSync {
    syncid: string;
    userid: string;
    tokenid: string;
    calendarid: string;
    lastsyncedat?:Date;
    isenabled: boolean;
}