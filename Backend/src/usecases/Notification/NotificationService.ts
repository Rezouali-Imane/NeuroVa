import { NotificationType } from "../../entities/Notification.js";
import type {
  CreateNotificationDTO,
  UpdateNotificationSettingsDTO,
} from "../../interfaces/dtos/Notification.dto.js";
import { NotificationRepository } from "../../interfaces/repositories/NotificationRepository.js";
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

  // Diagram signature: cancelNotification(notificationId)
  // userId remains optional for secured call paths.
  static async cancelNotification(notificationId: string, userid?: string) {
    if (!userid) {
      if (!notificationId) {
        throw new Error("Notification ID is required");
      }
      return NotificationRepository.delete(notificationId);
    }
    return DeleteNotification(notificationId, userid);
  }

  // Diagram signature: markAsRead(notificationId)
  // userId remains optional for secured call paths.
  static async markAsRead(notificationId: string, userid?: string) {
    if (!userid) {
      throw new Error("User ID is required to mark a notification as read.");
    }
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
    html: string,
    type: NotificationType = NotificationType.SYSTEM,
  ) {
    return sendEmailNotification(userid, subject, html, type);
  }

  static async getUserNotifications(userid: string) {
    return GetUserNotifications(userid);
  }
}
