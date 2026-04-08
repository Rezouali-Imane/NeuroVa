import type { Request, Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";

import { CreateNotification } from "../../usecases/Notification/CreatNotification.js";
import { DeleteNotification } from "../../usecases/Notification/DeleteNotification.js";
import { GetUserNotification } from "../../usecases/Notification/GetUserNotification.js";
import { MarkNotificationRead } from "../../usecases/Notification/MarkNotificationRead.js";
import { MarkAllNotificationsRead } from "../../usecases/Notification/MarkallNotificationRead.js";
import { getNotificationSettings } from "../../usecases/Notification/GetNotificationSettings.js";
import { UpdateNotificationSettings } from "../../usecases/Notification/UpdateNotificationSettings.js";
import { sendEmailNotification } from "../../usecases/Notification/SendEmailNotification.js";
import { SendPushNotification } from "../../usecases/Notification/SendPushNotification.js";

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
      const { userid } = (req as AuthRequest).user!;
      const { id } = req.params as { id: string };
       if (!id) throw new Error("Notification ID is required");
      await DeleteNotification(id, userid);
      res
        .status(200)
        .json({ success: true, message: "Notification deleted successfully" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async getUserNotifications(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const notifications = await GetUserNotification(userid as string);
      res.status(200).json({ success: true, data: notifications });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async markAsRead(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { id } = req.params as { id: string };
      await MarkNotificationRead(id, userid);
      res
        .status(200)
        .json({ success: true, message: "Notification marked as read" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async markAllAsRead(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      await MarkAllNotificationsRead(userid as string);
      res
        .status(200)
        .json({ success: true, message: "All notifications marked as read" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async getNotificationSettings(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const settings = await getNotificationSettings(userid as string);
      res.status(200).json({ success: true, data: settings });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async updateNotificationSettings(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const settingsData = req.body;
      const updatedSettings = await UpdateNotificationSettings(
        userid as string,
        settingsData,
      );
      res.status(200).json({ success: true, data: updatedSettings });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async sendEmailMessages(req: Request, res: Response) {
    try {
      const { userId, subject, message } = req.body;
      await sendEmailNotification(userId, subject, message);
      res
        .status(200)
        .json({ success: true, message: "Email sent successfully" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async sendPushNotification(req: Request, res: Response) {
    try {
      const { userId, title, message } = req.body;
      await SendPushNotification(userId, title, message);
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