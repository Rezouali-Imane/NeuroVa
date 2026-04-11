export enum NotificationType {
  TASK_REMINDER = "TASK_REMINDER",
  SESSION_START = "SESSION_START",
  SESSION_END = "SESSION_END",
  ACHIEVEMENT_EARNED = "ACHIEVEMENT_EARNED",
  DAILY_CHALLENGE = "DAILY_CHALLENGE",
  STUDY_ROOM_INVITE = "STUDY_ROOM_INVITE",
  SYSTEM = "SYSTEM",
}

export interface Notification {
notificationid: string;
userid: string;
sessionid?: string;
taskid?: string;
type: NotificationType;
title: string;
message: string;
scheduledtime?: Date;
isread: boolean;
createdat: Date;
}