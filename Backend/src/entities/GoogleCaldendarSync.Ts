export interface GoogleCalendarSync {
    syncid: string;
    userid: string;
    tokenid: string;
    googlecalendarid: string;
    lastsyncedat?: Date;
    isenabled: boolean;
}