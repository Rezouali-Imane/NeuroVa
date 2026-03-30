export interface Notification {
notificationid: string;
userid: string;
sessionid?: string;
taskid?: string;
type: string;
title: string;
message: string;
schduledtime?: Date;
isread: boolean;
createdat: Date;
}