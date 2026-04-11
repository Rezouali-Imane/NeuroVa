import { NotificationType } from "../../entities/Notification.js";
import type {
  CreateNotificationDTO,
  UpdateNotificationSettingsDTO,
} from "../../interfaces/dtos/Notification.dto.js";
import { CreateNotification } from "./CreateNotification.js";
import { DeleteNotification } from "./DeleteNotification.js";
import { getNotificationSettings } from "./GetNotificationSettings.js";
import { GetUserNotifications } from "./GetUserNotifications.js";
import { MarkAllNotificationsRead } from "./MarkAllNotificationRead.js";
import { MarkNotificationRead } from "./MarkNotificationRead.js";
import { sendEmailNotification } from "./SendEmailNotification.js";
import { SendPushNotification } from "./SendPushNotification.js";
import { UpdateNotificationSettings } from "./UpdateNotificationSettings.js";

export class NotificationService {
  static async scheduleNotification(
    userid: string,
    data: Omit<CreateNotificationDTO, "userid">,
  ) {
    return CreateNotification({ userid, ...data });
  }

  static async cancelNotification(notificationId: string, userid: string) {
    return DeleteNotification(notificationId, userid);
  }

  static async markAsRead(notificationId: string, userid: string) {
    return MarkNotificationRead(notificationId, userid);
  }

  static async markAllRead(userid: string) {
    return MarkAllNotificationsRead(userid);
  }

  static async getSettings(userid: string) {
    return getNotificationSettings(userid);
  }

  static async updateSettings(
    userid: string,
    data: UpdateNotificationSettingsDTO,
  ) {
    return UpdateNotificationSettings(userid, data);
  }

  static async sendPush(
    userid: string,
    title: string,
    message: string,
    type: NotificationType = NotificationType.SYSTEM,
  ) {
    return SendPushNotification(userid, title, message, type);
  }

  static async sendEmail(
    userid: string,
    subject: string,
    message: string,
    type: NotificationType = NotificationType.SYSTEM,
  ) {
    return sendEmailNotification(userid, subject, message, type);
  }

  static async getUserNotifications(userid: string) {
    return GetUserNotifications(userid);
  }
}
