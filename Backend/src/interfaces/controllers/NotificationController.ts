import type { Request, Response } from "express";

import { CreateNotification } from "../../usecases/Notification/CreatNotification.js";
import { DeleteNotification } from "../../usecases/Notification/DeleteNotification.js";
import { getUSerNotification } from "../../usecases/Notification/GetUserNotification.js";
import { markNotificationRead } from "../../usecases/Notification/MarkNotificationRead.js";
import { markAllNotificationsRead } from "../../usecases/Notification/MarkallNotificationRead.js";
import { getNotificationSettings } from "../../usecases/Notification/GetNotificationSettings.js";
import { UpdateNotificationSettings } from "../../usecases/Notification/UpdateNotificationSettings.js";
import { sendEmailMessages } from "../../usecases/Notification/SendEmailMessages.js";
import { sendPushNotification } from "../../usecases/Notification/SendPushNotification.js";

export const NotificationController = {

  async CreateNotification(req: Request, res: Response) {
    try {
      const notification = await CreateNotification(req.body);
      res.status(201).json({ success: true, data: notification });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },


  async DeleteNotification(req: Request, res: Response) {
    try {
      const { notificationid } = req.params as { notificationid: string };
      await DeleteNotification(notificationid);
      res
        .status(200)
        .json({ success: true, message: "Notification deleted successfully" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async getUserNotifications(req: Request, res: Response) {
    try {
      const { userid } = req.params;
      const notifications = await getUSerNotification(userid as string);
      res.status(200).json({ success: true, data: notifications });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async markAsRead(req: Request, res: Response) {
    try {
      const { notificationid } = req.params as { notificationid: string };
      await markNotificationRead(notificationid);
      res
        .status(200)
        .json({ success: true, message: "Notification marked as read" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async markAllAsRead(req: Request, res: Response) {
    try {
      const { userid } = req.params as { userid: string };
      await markAllNotificationsRead(userid as string);
      res
        .status(200)
        .json({ success: true, message: "All notifications marked as read" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async getSettings(req: Request, res: Response) {
    try {
      const { userid } = req.params;
      const settings = await getNotificationSettings(userid as string);
      res.status(200).json({ success: true, data: settings });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async updateSettings(req: Request, res: Response) {
    try {
    
      const { settingsid, userid } = req.params;
      const settingsData = req.body;
      const updatedSettings = await UpdateNotificationSettings(
        settingsid as string,
        userid as string,
        settingsData,
      );
      res.status(200).json({ success: true, data: updatedSettings });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async sendEmail(req: Request, res: Response) {
    try {
      const { userId, subject, message } = req.body;
      await sendEmailMessages(userId, subject, message);
      res
        .status(200)
        .json({ success: true, message: "Email sent successfully" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async sendPush(req: Request, res: Response) {
    try {
      const { userId, title, message } = req.body;
      await sendPushNotification(userId, title, message);
      res
        .status(200)
        .json({
          success: true,
          message: "Push notification sent successfully",
        });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



};
