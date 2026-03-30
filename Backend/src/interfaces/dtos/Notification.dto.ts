import { NotificationType } from "../../entities/Notification.js";

export interface CreateNotificationDTO {
  userid: string;
  type: NotificationType;
  title: string;
  message: string;
  sessionid?: string;
  taskid?: string;
  scheduledtime?: Date;
  isread: boolean;
  createdat: Date;
}

export interface UpdateNotificationSettingsDTO {
  pushenabled?: boolean;
  emailenabled?: boolean;
  taskreminders?: boolean;
  sessionreminders?: boolean;
  achievementalerts?: boolean;
  dailychallengealerts?: boolean;
  studyroominvites?: boolean;
  reminderminutesbefore?: number;
}

export interface NotificationResponseDTO {
  notificationid: string;
  type: NotificationType;
  title: string;
  message: string;
  isread: boolean;
  createdat: Date;
  sessionid?: string;
  taskid?: string;
}
