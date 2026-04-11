export interface NotificationSettings {
 settingsid: string;
 userid:string;
 pushenabled: boolean;
 emailenabled: boolean;
 taskreminders: boolean;
 sessionreminders: boolean;
 achievementalerts: boolean;
 dailychallengealerts: boolean;
 studyroominvites: boolean;
 reminderminutesbefore: number;
 updatedat: Date;
}