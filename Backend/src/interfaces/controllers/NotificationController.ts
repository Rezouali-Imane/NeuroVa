import type { Request, Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { NotificationType } from "../../entities/Notification.js";
import { NotificationService } from "../../usecases/Notification/NotificationService.js";

export const NotificationController = {

  async createNotification(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const notification = await NotificationService.scheduleNotification(userid, req.body);
      res.status(201).json({ success: true, data: notification });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },


  async cancelNotification(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { id } = req.params as { id: string };
       if (!id) throw new Error("Notification ID is required");
      await NotificationService.cancelNotification(id, userid);
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
      const notifications = await NotificationService.getUserNotifications(userid as string);
      res.status(200).json({ success: true, data: notifications });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async markAsRead(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { id } = req.params as { id: string };
      await NotificationService.markAsRead(id, userid);
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
      await NotificationService.markAllRead(userid as string);
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
      const settings = await NotificationService.getSettings(userid as string);
      res.status(200).json({ success: true, data: settings });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },




  async updateNotificationSettings(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const settingsData = req.body;
      const updatedSettings = await NotificationService.updateSettings(
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
      const { userid } = (req as AuthRequest).user!;
      const { subject, message, type } = req.body;
      await NotificationService.sendEmail(userid, subject, message, type ?? NotificationType.SYSTEM);
      res
        .status(200)
        .json({ success: true, message: "Email sent successfully" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },



  async sendPushNotification(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { title, message, type } = req.body;
      await NotificationService.sendPush(userid, title, message, type ?? NotificationType.SYSTEM);
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