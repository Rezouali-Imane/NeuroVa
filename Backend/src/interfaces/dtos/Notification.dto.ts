export interface CreateNotificationDTO {
notificationid: string;
userid: string;
sessionid?: string;
taskid?: string;
type: string;
title: string;
message: string;
scheduledtime?: Date;
isread: boolean;
createdat: Date;
}
export interface UpdateNotificationsettingsDTO {
settingsid: string;
userid:string;
pushenabled?: boolean;
emailenabled?: boolean;
taskreminders?: boolean;
sessionreminders?: boolean;
achievementalerts?: boolean;
dailychallengealerts?: boolean;
studyroominvites?: boolean;
reminderminutesbefore?: number;
updatedat: Date;
}
export interface NotificationResponseDTO {
notificationid: string;
userid: string;
isread: boolean;
}