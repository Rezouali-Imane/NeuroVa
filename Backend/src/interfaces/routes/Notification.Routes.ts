import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController.js";

const router = Router();

// Schedule notification
router.post("/", NotificationController.createNotification);

// Get all notifications for user
router.get("/", NotificationController.getUserNotifications);

// Mark a notification as read
router.patch("/:id/read", NotificationController.markAsRead);

// Mark all notifications as read
router.patch("/read-all", NotificationController.markAllAsRead);

// Delete a notification
router.delete("/:id", NotificationController.cancelNotification);

// Get notification settings
router.get("/settings", NotificationController.getNotificationSettings);

// Update notification settings
router.put("/settings", NotificationController.updateNotificationSettings);

// Send notifications
router.post("/email", NotificationController.sendEmailMessages);
router.post("/push", NotificationController.sendPushNotification);

export default router;