import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  CreateNotificationDTO,
  UpdateNotificationSettingsDTO,
  NotificationResponseDTO,
} from "../dtos/Notification.dto.js";

export const NotificationRepository = {
  async createNotification(data: CreateNotificationDTO) {
    return await prisma.notification.create({
      data: {
        userid: data.userid,
        type: data.type,
        title: data.title,
        message: data.message,
        sessionid: data.sessionid ?? null,
        taskid: data.taskid ?? null,
        scheduledtime: data.scheduledtime ?? null,
        isread: data.isread ?? false,
        createdat: data.createdat ?? new Date(),
      },
    });
  },
  async findAllByUser(userid: string) {
    return await prisma.notification.findMany({
      where: {
        userid: userid,
      },
    });
  },
  async findById(notificationid: string) {
    return await prisma.notification.findUnique({
      where: {
        notificationid: notificationid,
      },
    });
  },
  async markAsRead(notificationid: string) {
    return await prisma.notification.update({
      where: {
        notificationid: notificationid,
      },
      data: {
        isread: true,
      },
    });
  },
  async markAllAsRead(userid: string) {
    return await prisma.notification.updateMany({
      where: {
        userid: userid,
        isread: false,
      },
      data: {
        isread: true,
      },
    });
  },
  async delete(notificationid: string) {
    return await prisma.notification.delete({
      where: {
        notificationid: notificationid,
      },
    });
  },
  async getSettings(userid: string) {
    return await prisma.notificationsettings.findUnique({
      where: {
        userid: userid,
      },
    });
  },
  async updateSettings(userid: string, data: UpdateNotificationSettingsDTO) {
    const updateData: any = {};

    if (data.pushenabled !== undefined)
      updateData.pushenabled = data.pushenabled;
    if (data.emailenabled !== undefined)
      updateData.emailenabled = data.emailenabled;
    if (data.taskreminders !== undefined)
      updateData.taskreminders = data.taskreminders;
    if (data.sessionreminders !== undefined)
      updateData.sessionreminders = data.sessionreminders;
    if (data.achievementalerts !== undefined)
      updateData.achievementalerts = data.achievementalerts;
    if (data.dailychallengealerts !== undefined)
      updateData.dailychallengealerts = data.dailychallengealerts;
    if (data.studyroominvites !== undefined)
      updateData.studyroominvites = data.studyroominvites;
    if (data.reminderminutesbefore !== undefined)
      updateData.reminderminutesbefore = data.reminderminutesbefore;

    updateData.updatedat = new Date();

    return await prisma.notificationsettings.upsert({
      where: { userid },
      update: updateData,
      create: {
        userid,
        ...updateData,
      },
    });
  },

  // Backward-compatible alias while naming is normalized.
  async CreateNotification(data: CreateNotificationDTO) {
    return this.createNotification(data);
  },
};
